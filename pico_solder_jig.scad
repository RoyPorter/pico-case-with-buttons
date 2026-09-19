/* =============================================================
   Soldering jig for the Pico case tact switches.

   Holds a 6x6 tact switch in exactly the position the case lid
   expects, with the Pico laid COMPONENT SIDE DOWN on top, so the
   whole solder side -- every pad and track -- is open to the iron.

   The switch drops into a pocket actuator-first. An actuator hole
   runs right through the base, so you can push the switch firmly
   up against the board with a pin while tacking the first leg.

   Board figures from the Pico datasheet Fig 3; switch position
   matches pico_case.scad.
   ============================================================= */

/* ---- board, datasheet ---------------------------------------- */
pcb_l   = 51.0;
pcb_w   = 21.0;

/* ---- switch, must match the case ------------------------------ */
sw_body    = 6.0;
sw_body_h  = 3.5;
sw_act_d   = 3.5;
pin_y      = 1.61;    // pin centre in from the long edge
sw_inboard = 3.25;    // body centre, in from the soldered leg line

include <slots.inc>

/* Buttons come from DEFAULT_BUTTONS in slots.inc, so the case and the
   jig cannot drift apart -- edit it in ONE place. A -D on the command
   line still wins, because it is appended after this assignment.     */
buttons = DEFAULT_BUTTONS;

/* ---- jig ------------------------------------------------------ */
fit_l     = 0.7;    // slack along the board length (USB end needs room)
fit_w     = 0.4;    // slack across the width
corner_r  = 1.4;    // relief at the pocket corners, so a squarer PCB
                    // corner cannot bind before the edges touch
lead_in   = 0.8;    // chamfer at the pocket mouth, to drop the board in
wall      = 4.0;    // outer wall, wide enough to label
rim_w     = 2.0;    // board support width; pad field is bare to 2.3mm
cav_d     = 4.0;    // clearance for USB shell etc. (tallest ~2.9mm)
base_t    = 4.0;
lip_h     = 1.2;    // lip standing proud of the board
pocket_fit= 0.25;
act_hole  = 4.5;
collar_w  = 1.3;
collar_dr = 0.15;   // collar top sits below the board plane
usb_notch = 17.0;   // clears the connector shell AND its side tabs
usb_deep  = 3.0;    // extra reach inboard, past the overhang
grab_w    = 11.0;   // push-out slots at mid length
$fn = 48;

/* ---- derived -------------------------------------------------- */
in_l  = pcb_l + fit_l;
in_w  = pcb_w + fit_w;
out_l = in_l + 2*wall;
out_w = in_w + 2*wall;
z_cav = base_t;              // cavity floor
z_brd = base_t + cav_d;      // board plane
z_top = z_brd + lip_h;
// The pocket is deliberately loose so the board drops in, so the switch
// pockets are referenced to a DATUM CORNER rather than the pocket centre:
// push the board hard into the far end and the PIN 1 edge, and the
// slack no longer affects where the actuator lands.
bx0 = wall + fit_l;      // board pushed to the far (non-USB) end
by0 = wall + fit_w;      // board pushed to the PIN 1 edge (high Y)

// The board goes in FLIPPED, so the pin-1 edge lands at high Y and an
// edge-0 button ends up on the far side of the jig.
function j_cx(n) = bx0 + b_along(n);
function j_cy(n) = by0 + (b_edge(n) == 0 ? pcb_w - pin_y - sw_inboard
                                         : pin_y + sw_inboard);
z_pock = z_brd - sw_body_h;  // pocket floor

assert(cav_d > 3.2, "cavity too shallow for the USB shell");
assert(rim_w <= 2.3, "board support reaches past the bare pad field");
assert(z_pock > z_cav, "switch pocket floor is below the cavity floor");
for (b = buttons) assert(slot_i(b) >= 0, str("unknown button slot: ", b));
for (b = buttons) assert(j_cy(b) - by0 - sw_body/2 > 0
                      && j_cy(b) - by0 + sw_body/2 < pcb_w,
       "switch overhangs the board once flipped");
echo(str("jig ", out_l, " x ", out_w, " x ", z_top, " mm"));
for (b = buttons) echo(str("pocket ", b, "  x=", j_cx(b), "  y=", j_cy(b)));
echo(str("board sits ", cav_d, "mm above the cavity floor"));
echo(str("pocket clearance  ", fit_l/2, "mm per end, ", fit_w/2, "mm per side"));

module rbox(l,w,h,r){ hull() for(x=[r,l-r],y=[r,w-r]) translate([x,y,0]) cylinder(r=r,h=h); }

module jig() {
    difference() {
        union() {
            difference() {
                rbox(out_l, out_w, z_top, 3);
                // board pocket, above the support rim
                translate([wall, wall, z_brd]) rbox(in_l, in_w, lip_h + 1, 1.0);
                // component cavity, inset by the support rim
                translate([wall + rim_w, wall + rim_w, z_cav])
                    rbox(in_l - 2*rim_w, in_w - 2*rim_w, cav_d + 0.01, 1.0);
                // channel for the overhanging USB shell
                translate([-1, out_w/2 - usb_notch/2, z_cav])
                    cube([wall + rim_w + 1 + usb_deep, usb_notch, z_top]);
                // relief at each pocket corner
                for (x = [wall, wall + in_l], y = [wall, wall + in_w])
                    translate([x, y, z_brd - 0.5])
                        cylinder(d = corner_r*2, h = lip_h + 2);
                // chamfered mouth so the board drops in rather than presses
                hull() {
                    translate([wall, wall, z_top - lead_in])
                        rbox(in_l, in_w, 0.01, 1.0);
                    translate([wall - lead_in, wall - lead_in, z_top])
                        rbox(in_l + 2*lead_in, in_w + 2*lead_in, 0.01, 1.0);
                }
                // push-out slot, so the board can be lifted from below
                translate([out_l/2 - grab_w/2, -1, z_cav])
                    cube([grab_w, wall + rim_w + 1, z_top]);
                // engraved labels, so the board cannot go in the wrong way
                translate([wall + 7, wall/2, z_top - 0.6])
                    linear_extrude(1) text("USB", size=2.8, halign="center", valign="center");
                translate([out_l/2, out_w - wall/2, z_top - 0.6])
                    linear_extrude(1) text("PIN 1 EDGE - PUSH TO HERE", size=2.6,
                        halign="center", valign="center");
                // datum arrow on the far end wall
                translate([out_l - wall/2, out_w/2, z_top - 0.6])
                    rotate([0, 0, 90]) linear_extrude(1)
                        text("PUSH >>", size=2.8, halign="center", valign="center");
            }
            // collars added AFTER the cavity, or the cavity would eat them
            for (b = buttons)
                translate([j_cx(b), j_cy(b), z_cav])
                    linear_extrude(z_brd - collar_dr - z_cav)
                        square(sw_body + 2*pocket_fit + 2*collar_w, center=true);
        }
        // one pocket + actuator hole per button, open at the board plane
        for (b = buttons) {
            translate([j_cx(b), j_cy(b), z_pock])
                linear_extrude(z_top) square(sw_body + 2*pocket_fit, center=true);
            translate([j_cx(b), j_cy(b), -1])
                cylinder(d = act_hole, h = z_pock + 1);
        }
    }
}
jig();
