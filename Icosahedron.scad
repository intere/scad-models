/*****************************************************************
* 20-sided die (counter) Dice box.  Based on the Icosahedron 
* model: by Adam Anderson (see his header below).
*************************************************************/

/*****************************************************************
* Icosahedron   By Adam Anderson
* 
* This module allows for the creation of an icosahedron scaled up 
* by a factor determined by the module parameter. 
* The coordinates for the vertices were taken from
* http://www.sacred-geometry.es/?q=en/content/phi-sacred-solids
*************************************************************/

// This module is what the dice box is based on.  This is Adam's code
module icosahedron(a = 2) {
    phi = a * ((1 + sqrt(5)) / 2);
    polyhedron(
        points = [
            [0,-phi, a], [0, phi, a], [0, phi, -a], [0, -phi, -a], [a, 0, phi], [-a, 0, phi], [-a, 0, -phi], 
            [a, 0, -phi], [phi, a, 0], [-phi, a, 0], [-phi, -a, 0], [phi, -a, 0]    
        ],
        faces = [
            [0,5,4], [0,4,11], [11,4,8], [11,8,7], [4,5,1], [4,1,8], [8,1,2], [8,2,7], [1,5,9], [1,9,2], 
            [2,9,6], [2,6,7], [9,5,10], [9,10,6], [6,10,3], [6,3,7], [10,5,0], [10,0,3], [3,0,11], [3,11,7]
        ]    
    );
}

// This module arranges the numbers so that they align with the top of the dice box.
module top_die_counter(a = 2) {
    chars = [ "18", "17", "16", "20", "19" ];
    
    for(idx = [0:4]) {
        rotate([90, 180, 90 - (idx * 72.5)])
        translate([0, a * 1.25, 0.82 * a])
        rotate([-55,0,0])
        linear_extrude(height=4, convexity=4)    
        text(chars[idx], a * 15 / 30, font="Bitstream Vera Sans", halign="center", valign="center");
    }
}

// This module arranges the numbers so that they align with the bottom of the dice box.
// There are 3 rows, the first row and the third row are upside down (by design).s
module bottom_die_counter(a = 2) {
    row_1_chars = [ ".9", "7", "15", "13", "11" ];
    row_2_chars = [ "14", "12", "10", "8", "6." ];
    row_3_chars = [ "4", "3", "2", "1", "5" ];
    
    // First Row
    for(idx = [0:4]) {
        rotate([90, 180, 90 - (idx * 72.5)])
        translate([0, 0.35 * a, 1.45 * a])
        rotate([10,0,180])
        linear_extrude(height=4, convexity=4)    
        text(row_1_chars[idx], a * 15 / 30, font="Bitstream Vera Sans", halign="center", valign="center");
    }
    
    // Second Row (upside down)
    for(idx = [0:4]) {
        rotate([-90, 180, 90 - (idx * 72.5)])
        translate([0, .25 * a, 1.45 * a])
        rotate([10,0,180])
        linear_extrude(height=4, convexity=4)    
        text(row_2_chars[idx], a * 15 / 30, font="Bitstream Vera Sans", halign="center", valign="center");
    }    
    
    // Third Row (bottom of die)
    for(idx = [0:4]) {
        rotate([-90, 180, 90 - (idx * 72.5)])
        translate([0, a * 1.25, 0.82 * a])
        rotate([-55,0,0])
        linear_extrude(height=4, convexity=4)    
        text(row_3_chars[idx], a * 15 / 30, font="Bitstream Vera Sans", halign="center", valign="center");
    }
    
}

// Slices the icosahedron to carve out the top of the dice box
module top_icosahedron(a = 2) {
    intersection() {
        rotate([0, 32, 0]) icosahedron(a);
        translate([0, 0, -2.85 * a]) 
        cube(4 * a, center = true);
    }
}

// Slices the icosahedron to carve out the bottom of the dice box
module bottom_icosahedron(a = 2) {
    intersection() {
        rotate([0, 32, 0]) icosahedron(a);
        translate([0, 0, 1.15 * a]) 
        cube(4 * a, center = true);
    }
}

// Creates the top of the dice box by doing the following:
// 1. Render the top portion of the icosahedron
// 2. Etch (difference) the numbers around the die
// 3. Add the magnet pockets (for 10mm magnets)
module d20_top(a = 50) {
    difference() {
        union() {
            difference() {
                difference() {
                    top_icosahedron(a);
                    top_icosahedron(a-4);
                }
                top_die_counter(a);
            }
            translate([-1.23 * a, 0, -0.85 * a])
            magnet_pocket_top(a);
            
            translate([-0.4 * a, 1.2 * a, -0.85 * a])
            rotate([0, 0, -75])
            magnet_pocket_top(a);
            
            translate([-0.4 * a, -1.2 * a, -0.85 * a])
            rotate([0, 0, 75])
            magnet_pocket_top(a);
            
            translate([a, 0.75 * a, -0.85 * a])
            rotate([0, 0, -140])
            magnet_pocket_top(a);
            
            translate([a, -0.75 * a, -0.85 * a])
            rotate([0, 0, -230])
            magnet_pocket_top(a);
        }
        
        // The Magnet Pockets:
        translate([-1.23 * a, 0, -0.85 * a])
        magnet_pocket();
        
        translate([-0.4 * a, 1.2 * a, -0.85 * a])
        rotate([0, 0, -75])
        magnet_pocket();
        
        translate([-0.4 * a, -1.2 * a, -0.85 * a])
        rotate([0, 0, 75])
        magnet_pocket();
        
        translate([a, 0.75 * a, -0.85 * a])
        rotate([0, 0, -140])
        magnet_pocket();
        
        translate([a, -0.75 * a, -0.85 * a])
        rotate([0, 0, -230])
        magnet_pocket();
    }
}

// A Module that creates a "magnet pocket" for the top of the dice box.
module magnet_pocket_top(a = 50) {
    rotate([180, 0, 0])
    cylinder(d1 = a/2, d2 = 2, a/5);
}

module magnet_pocket() {
    cylinder(d=11, d=11, 3);
}

// Creates the bottom of the dice box by doing the following:
// 1. Render the bottom portion of the icosahedron
// 2. Etch (difference) the numbers around the die
// 3. Add the magnet pockets (for 10mm magnets)
module d20_bottom(a = 50) {
    difference() {
        union() {
            difference() {
                difference() {
                    bottom_icosahedron(a);
                    translate([0, 0, -4])
                    bottom_icosahedron(a-4);
                }
                bottom_die_counter(a);
            }        

            translate([-1.23 * a, 0, -0.85 * a])
            magnet_pocket_support_bottom(a);
            
            translate([-0.4 * a, 1.2 * a, -0.85 * a])
            rotate([0, 0, -75])
            magnet_pocket_support_bottom(a);
            
            translate([-0.4 * a, -1.2 * a, -0.85 * a])
            rotate([0, 0, 75])
            magnet_pocket_support_bottom(a);
            
            translate([a, 0.75 * a, -0.85 * a])
            rotate([0, 0, -140])
            magnet_pocket_support_bottom(a);
            
            translate([a, -0.75 * a, -0.85 * a])
            rotate([0, 0, -230])
            magnet_pocket_support_bottom(a);
        }
        
        // Magnet Pockets
        translate([-1.23 * a, 0, -0.85 * a])
        magnet_pocket();
        
        translate([-0.4 * a, 1.2 * a, -0.85 * a])
        rotate([0, 0, -75])
        magnet_pocket();
        
        translate([-0.4 * a, -1.2 * a, -0.85 * a])
        rotate([0, 0, 75])
        magnet_pocket();
        
        translate([a, 0.75 * a, -0.85 * a])
        rotate([0, 0, -140])
        magnet_pocket();
        
        translate([a, -0.75 * a, -0.85 * a])
        rotate([0, 0, -230])
        magnet_pocket();
    }
}

// The "magnet pockets" for the bottom of the dice box
module magnet_pocket_support_bottom(a = 50) {
   cylinder(d1 = 4*a/6+1, d2 = 5*a/8, a/5);
}

// Displays the top and bottom with a bit of space between them so that you can see how they fit together
module display(a = 50) {
    translate([0, 0, -20])
    d20_top(a);
    translate([0, 0, 20])
    d20_bottom(a);
}

module main() {
    
    // I've determined this to be the approrpiate size:
    // top = 122mm x 129mm x 42 mm (approx)
    // bottom = 136mm x 129mm x 110 mm
    a = 40;
    
    // Do you want to see the top and bottom at the same time?
    display(a);
    
    // Uncomment the next 2 lines to render the top of the box:
    // rotate([0, 180, 0])
    // d20_top(a);
    
    // Uncomment the next line to render the bottom of the box:
    // d20_bottom(a);
}


main();
