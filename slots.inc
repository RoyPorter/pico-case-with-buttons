/* ---- button slots -------------------------------------------------
   Each is a GND + GPIO pair exactly two holes (5.08mm) apart, so a
   6x6 tact switch (legs 4.5mm apart) drops straight in; the legs flex.
   "along" is mm from the USB edge; edge 0 = pins 1-20, 1 = pins 21-40.
   Only slots whose 6x6 footprint is clear of components on a real
   Pico are listed -- the other eight candidates hit the LED, BOOTSEL,
   a SOIC, or passives. See README.
   Two slots on the SAME edge need their "along" values >= 6.4mm
   apart, so GP12+GP15 and GP19+GP16 are mutually exclusive.
   Maximum simultaneously fittable: 3.

   Two pairs sit directly opposite each other (same "along", opposite
   edges), which looks tidiest on the lid:
       GP15 + GP16   at along 47.09   <- recommended pair
       GP12 + GP19   at along 42.01
   Their body centres end up 11.28mm apart across the board, so they
   clear each other by 5.28mm.
   ------------------------------------------------------------------ */
/* THE button list. Both the case and the jig read this, so they can
   never disagree. Override for a one-off export with:
       openscad -D 'buttons=["GP15"]' ...                               */
DEFAULT_BUTTONS = ["GP15", "GP16"];

SLOT_NAME  = ["GP12", "GP15", "GP20", "GP19", "GP16"];
SLOT_ALONG = [ 42.01,  47.09,  34.39,  42.01,  47.09];
SLOT_EDGE  = [     0,      0,      1,      1,      1];
SLOT_PINS  = ["18+16","18+20","28+26","23+25","23+21"];

function slot_i(n, i = 0) =
    i >= len(SLOT_NAME) ? -1 : (SLOT_NAME[i] == n ? i : slot_i(n, i + 1));
function b_along(n) = SLOT_ALONG[slot_i(n)];
function b_edge(n)  = SLOT_EDGE[slot_i(n)];
