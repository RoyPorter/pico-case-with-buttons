/* =============================================================
   Raspberry Pi Pico case with optional tact-switch buttons
   Fits a bare Pico plus up to three 6x6mm tact switches soldered
   across GND+GPIO pin pairs (see slots.inc). Two printed parts.

   Board figures are from the Pico datasheet, Figure 3.
   ============================================================= */

part = "all";   // [all, base, lid, assembled]

/* ---- board: datasheet values, leave alone ------------------ */
pcb_l    = 51.0;
pcb_w    = 21.0;
pcb_t    = 1.0;
pin1_x   = 1.37;   // (51 - 19*2.54)/2, pin 1 centre from USB edge
pin_p    = 2.54;   // pin pitch
pin_y    = 1.61;   // pin centre in from the long edge

/* ---- the tact switch --------------------------------------- */
sw_body    = 6.0;    // 6 x 6 mm body
sw_body_h  = 3.5;    // body height above the PCB
sw_act_d   = 3.5;    // actuator diameter - MEASURE YOURS, they vary 3.0-3.8
act_clear  = 0.7;    // added to the lid hole; 0.7 is snug, 1.4 is forgiving
sw_total_h = 7.0;    // PCB surface to actuator top ("6x6x7" switch)
sw_inboard = 3.25;   // body centre, in from the soldered leg line

include <slots.inc>

/* Buttons come from DEFAULT_BUTTONS in slots.inc, so the case and the
   jig cannot drift apart -- edit it in ONE place. A -D on the command
   line still wins, because it is appended after this assignment.     */
buttons = DEFAULT_BUTTONS;

/* ---- fit and walls ----------------------------------------- */
fit       = 0.4;    // total slack around the PCB outline
wall      = 2.0;
floor_t   = 1.8;
lid_t     = 1.6;
under_pcb = 2.0;    // room for clipped legs and solder
over_pcb  = 4.2;    // must exceed sw_body_h (3.5)
corner_r  = 3.0;
ledge     = 2.0;    // end shelves the PCB rests on
pad_y     = [4, 17]; // support pads across the width, clear of the RP2040
// Lengthwise support stations, as a fraction of the internal length.
// [0.5] = one station (2 pads). [0.3,0.5,0.7] = three (6 pads).
// Pads sit UNDER the board, where the Pico is bare, so extra ones are safe.
pad_frac  = [0.5];
// NOTE: there are deliberately no lid bosses pressing on the board face.
// The Pico's top side carries a SOT-23 at board x 16.0-17.9, y 25.2-26.8
// and passives near x 5.5-6.3, so any mid-board boss lands on something.
// The board is held down by the rims bearing on the bare pad field instead.

/* ---- openings ---------------------------------------------- */
usb_w     = 12.0;   // wide enough for a plug moulding
led_x     = 4.80;   // LED: datasheet Fig 3 diode symbol + photo agree
led_y     = 4.80;   // in from the pin-1 long edge
led_win_d = 5.5;    // +/-2.75mm slack around a corroborated position
led_skin  = 0.8;    // lid left this thin so the LED glows through
bootsel   = false;  // poke-hole over BOOTSEL, for reflashing without opening
bootsel_x = 11.84;  // measured off a photo of the actual board
bootsel_y = 6.95;   // in from the pin-1 long edge
bootsel_d = 3.5;

/* ---- snap fit ---------------------------------------------- */
rim_t     = 1.4;   // stays inside the 2.3mm component-free pad field
// rim_h is derived: it must reach the board to hold it down
rim_gap   = 0.25;
barb      = 0.45;

$fn = 64;

/* ---- derived ------------------------------------------------ */
in_l  = pcb_l + fit;
in_w  = pcb_w + fit;
out_l = in_l + 2*wall;
out_w = in_w + 2*wall;

z_pcb_b = floor_t + under_pcb;
z_pcb_t = z_pcb_b + pcb_t;
z_lid   = z_pcb_t + over_pcb;      // lid underside
out_h   = z_lid + lid_t;

px = wall + fit/2;                 // PCB origin inside the case
py = wall + fit/2;
r_in = max(corner_r - wall, 0.6);

function b_cx(n) = px + b_along(n);
function b_cy(n) = b_edge(n) == 0 ? py + pin_y + sw_inboard
                                  : py + pcb_w - pin_y - sw_inboard;

rim_h   = z_lid - z_pcb_t;         // rim presses on the board edge
act_proud = sw_total_h - over_pcb - lid_t;   // actuator above the lid

echo(str("case  ", out_l, " x ", out_w, " x ", out_h, " mm"));
for (b = buttons) echo(str("button ", b, " (pins ", SLOT_PINS[slot_i(b)],
     ")  centre x=", b_cx(b), " y=", b_cy(b)));
echo(str("actuator stands proud of lid by ", act_proud, " mm"));

/* ---- design rule checks ------------------------------------- */
assert(over_pcb > sw_body_h,
       "lid would crush the switch body: raise over_pcb");
assert(act_proud > 0.5,
       "actuator does not reach through the lid: use a taller switch or cut over_pcb");
for (b = buttons) assert(slot_i(b) >= 0, str("unknown button slot: ", b));
assert(len(buttons) >= 1, "fit at least one button");
for (b = buttons) assert(b_cx(b) + sw_body/2 <= px + pcb_l,
       "switch body hangs off the end of the PCB");
for (b = buttons) assert(b_cy(b) + sw_body/2 <= py + pcb_w
                      && b_cy(b) - sw_body/2 >= py,
       "switch body hangs off the side of the PCB");
for (b = buttons) assert(b_cx(b) + (sw_act_d + act_clear)/2 < wall + in_l,
       "actuator hole breaks into the end wall");
for (i = [0:len(buttons)-1]) for (j = [0:len(buttons)-1])
    assert(i >= j || b_edge(buttons[i]) != b_edge(buttons[j])
           || abs(b_along(buttons[i]) - b_along(buttons[j])) >= sw_body + 0.4,
           str("buttons ", buttons[i], " and ", buttons[j],
               " overlap: same edge, centres under 6.4mm apart"));
assert(px + led_x + led_win_d/2 < wall + in_l && py + led_y + led_win_d/2 < wall + in_w,
       "LED window breaks into a wall");
assert(led_skin < lid_t, "LED window would punch through the lid");
assert(py + led_y - led_win_d/2 > wall + rim_gap + rim_t,
       "LED window cuts into the lid rim");
assert(!bootsel || sqrt(pow(bootsel_x - led_x, 2) + pow(bootsel_y - led_y, 2))
       > (bootsel_d + led_win_d)/2, "BOOTSEL hole overlaps the LED window");
assert(usb_w + 2*corner_r < out_w, "USB opening leaves no end wall");
assert(ledge * 2 < in_l, "shelves overlap");
// the rim must stay inside the component-free pad field along each edge
assert(rim_gap + rim_t <= 2.3,
       "rim reaches past the pad field and onto components");
// and it must not foul the switch body
for (b = buttons) assert(
    b_edge(b) == 0 ? rim_gap + rim_t < b_cy(b) - sw_body/2 - py
                   : rim_gap + rim_t < (py + pcb_w) - (b_cy(b) + sw_body/2),
    str("rim collides with the ", b, " switch body"));

echo(str("clearance lid-to-switch-body  ", over_pcb - sw_body_h, " mm"));
echo(str("PCB support shelves           ", ledge, " mm at each end"));

/* ---- helpers ------------------------------------------------ */
module rbox(l, w, h, r) {
    hull() for (x = [r, l - r], y = [r, w - r])
        translate([x, y, 0]) cylinder(r = r, h = h);
}

module usb_hole() {
    // Open-topped in the base; the lid closes it off.
    translate([-1, out_w/2 - usb_w/2, z_pcb_b - 0.6])
        cube([wall + 2, usb_w, out_h]);
}

module snap_groove() {
    // continuous groove in the inner face of each long wall
    for (s = [0, 1])
        translate([wall + in_l/2,
                   s == 0 ? wall - barb/2 : wall + in_w + barb/2,
                   z_lid - rim_h + 0.8])
            cube([in_l - 6, barb, 1.0], center = true);
}

/* ---- base --------------------------------------------------- */
module base() {
    difference() {
        union() {
            difference() {
                rbox(out_l, out_w, z_lid, corner_r);
                // cavity above the shelves: full PCB footprint
                translate([wall, wall, z_pcb_b])
                    rbox(in_l, in_w, out_h, r_in);
                // cavity below: inset at the ends only, leaving shelves
                translate([wall + ledge, wall, floor_t])
                    cube([in_l - 2*ledge, in_w, under_pcb + 0.01]);
                snap_groove();
            }
            // two centre pads so a 51mm board cannot sag
            for (f = pad_frac, y = pad_y)
                translate([wall + in_l*f, py + y, floor_t])
                    cylinder(d = 4, h = under_pcb);
        }
        usb_hole();
    }
}

/* ---- lid ---------------------------------------------------- */
module lid() {
    difference() {
        union() {
            translate([0, 0, z_lid]) rbox(out_l, out_w, lid_t, corner_r);
            // rim down the two long sides only
            for (s = [0, 1])
                translate([wall + rim_gap,
                           s == 0 ? wall + rim_gap : wall + in_w - rim_t - rim_gap,
                           z_lid - rim_h])
                    cube([in_l - 2*rim_gap, rim_t, rim_h]);
            // barbs that click into the groove
            for (s = [0, 1])
                translate([wall + in_l/2,
                           s == 0 ? wall + rim_gap : wall + in_w - rim_gap,
                           z_lid - rim_h + 0.8])
                    rotate([45, 0, 0])
                        cube([in_l - 6, barb*1.4, barb*1.4], center = true);
        }
        // one actuator hole per fitted button
        for (b = buttons)
            translate([b_cx(b), b_cy(b), z_lid - 1])
                cylinder(d = sw_act_d + act_clear, h = lid_t + 2);
        // LED light window: blind pocket, leaves led_skin of plastic
        translate([px + led_x, py + led_y, z_lid - 0.5])
            cylinder(d = led_win_d, h = lid_t - led_skin + 0.5);
        // clearance around each switch body. Sized +0.2mm a side so it
        // stops short of the rim, keeping the rim continuous.
        for (b = buttons)
            translate([b_cx(b) - sw_body/2 - 0.2, b_cy(b) - sw_body/2 - 0.2,
                       z_pcb_t - 0.1])
                cube([sw_body + 0.4, sw_body + 0.4, z_lid - z_pcb_t + 0.2]);
        // optional BOOTSEL poke-hole
        if (bootsel)
            translate([px + bootsel_x, py + bootsel_y, z_lid - 1])
                cylinder(d = bootsel_d, h = lid_t + 2);
        // notch matching the USB opening
        translate([-1, out_w/2 - usb_w/2, z_lid - rim_h - 1])
            cube([wall + 1 + rim_t, usb_w, rim_h + 1]);
    }
}

/* ---- mock board, for visual checking only ------------------- */
module pcb_mock() {
    color("green") translate([px, py, z_pcb_b]) cube([pcb_l, pcb_w, pcb_t]);
    // micro-USB shell
    color("silver")
        translate([px - 1.8, out_w/2 - 4, z_pcb_t]) cube([9, 8, 2.9]);
    // tact switch
    for (b = buttons) {
        color("dimgray")
            translate([b_cx(b) - sw_body/2, b_cy(b) - sw_body/2, z_pcb_t])
                cube([sw_body, sw_body, sw_body_h]);
        color("black")
            translate([b_cx(b), b_cy(b), z_pcb_t])
                cylinder(d = sw_act_d, h = sw_total_h);
    }
}

/* ---- output ------------------------------------------------- */
if (part == "base") base();
else if (part == "lid") lid();
else if (part == "assembled") { base(); lid(); %pcb_mock(); }
else if (part == "sec_long") {   // lengthwise cut through the button
    difference() {
        union() { base(); lid(); }
        translate([-1, b_cy(buttons[0]), -1]) cube([out_l + 2, out_w, out_h + 2]);
    }
}
else if (part == "sec_cross") {  // cross-cut through the button
    difference() {
        union() { base(); lid(); }
        translate([b_cx(buttons[0]), -1, -1]) cube([out_l, out_w + 2, out_h + 2]);
    }
}
else { // all: parts side by side
    base();
    translate([0, out_w + 6, 0]) lid();
}
