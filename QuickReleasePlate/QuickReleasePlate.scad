// Tripod quick release plate
//
// Nominally designed for MX 3000 tripod (40x43mm, 1/4" hole)
// Adjust the measurements set below to your own needs. 
//
// Eric Myers <myerse@newpaltz.edu> - 22 May 2018
// Dept. of Physics and Astronomy, SUNY New Paltz
//////////////////////////////////////////////////

W  = 40.0;          // width of bottom (in the x direction)
L  = 43.0;          // Length at the bottom (in the y direction)
D  = 5.0;           // Indent at the top, relative to bottom
//H  = 8.0;           // Height of platform
T  = 2.0;           // Thickness (sets the scale)
R1 = 6.4/2;         // Smaller radius of screw body
R2 = 9.4/2;         // Larger radius of screw head
H2 = 6.5;           // Height of screw head   
TextSize = 16.0;    // Height of text, in mm (not pt)


// Thermal expansion fudge factor (ff) accounts for width of
// the plastic, which is not included in g-code (usually).
// Aaron Nelson suggested 0.65mm in general.

ff = 0.65;

// A maximum size, longer than all main dimensions, by a bit
maxL = max(W,L)+2*D+T;   // bigger by all lengths, by a bit
echo("Maximum of all lengths is ", maxL, "mm");

// The overall height is computed from the height of the screw head
// and the thickness

H = H2 +T;
echo("Overall height: ", H, "mm");


//--
// Use this module to put the bevel on the object.
// It creates a cube object out at a distance 'dist'
// and tilted by the right amount.    The angle theta is the
// direction in the x-y plane.

module bevel_slicer(theta, dist, inset, height){
    // inset is how far in top is relative to the bottom,
    // height is the height of the object
    tilt = atan(inset/height);
    echo("tilt angle is ", tilt);

    rotate([0,0,theta])
    translate([ dist/2, -maxL/2, -height/2])  
    rotate([0, -tilt, 0])    cube([dist, maxL, 1.3*height], center=false);
}


//--
// The main block creates the body of the object, with the 
// hollowed out underside and cross bars. 

module main_block() {
    difference(){
        // Initial block, from which we carve
        cube( [W, L, H], center=true);
        
        // Remove sloped edges
        bevel_slicer(0.0, W, D, H);
        bevel_slicer(180.0, W, D, H);
        bevel_slicer(90, L, D, H);
        bevel_slicer(270, L, D, H);
        
        // Hollow out the bottom
       translate([0, 0, -T])   cube([W-2*D-T,L-2*D-T, H], center=true);
    }
    
    // Support for screw hole
    R3=sqrt(L*L/36 + W*W/36);
    cylinder(r=R3, h=H, center=true, $fn=50);
    
    // Now add the cross bars
    
    translate([0,+L/6,0])   cube([W-2*D, T, H], center=true);
    translate([0,-L/6,0])     cube([W-2*D, T, H], center=true);
    
    translate([+W/6,0,0])   cube([T, L-2*D, H], center=true);
    translate([-W/6,0,0])   cube([T, L-2*D, H], center=true);
}




// Now drill the holes and write the text

difference(){
    main_block();
    
    // Hole for screw body (eg 1/4-20)
    cylinder(r=R1+ff, h=H+T+ff, center=true,$fn=100);
   
    // Hole for the head of screw
     translate([0,0,-(H-H2)/2]) cylinder(r=R2+ff, h=H2, center=true, $fn=100);
    
    // Text for the x dimension (width W)
    labelW = str(W,"mm");
    echo("Width label: ",labelW);
      translate([0,-L/2+0.5*TextSize,H/2])
        linear_extrude(2*ff, center=true, convexity=4)
          resize([TextSize,0], auto=true)
            text(labelW, valign="center", halign="center");
    
    // Text for the y dimension (length L)
    labelL = str(L,"mm");
    echo("Length label:", labelL);
      translate([W/2-0.5*TextSize,0,H/2])  // Shift it up and out
        linear_extrude(2*ff, center=true, convexity=4)
           rotate([0,0,90])   // Turns text orientation
           resize([TextSize,0], auto=true)
           text(labelL, valign="center", halign="center");
    
    
    // Take away half for inspection
    *translate([0, -maxL/2 -R1 , 0])     cube([maxL, maxL, 2*H], center=true);
}