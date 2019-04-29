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
module top_die_with_chars(a = 50, chars) {
    
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
module bottom_die_counter(a = 50, row_1_chars, row_2_chars, row_3_chars) {
    
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
// 3. Add the magnet pocket supports
// 4. Carve out the magnet pockets (for 10mm magnets)
module d20_top(a = 50, chars) {
    translations = [ 
        [-1.23 * a, 0, -0.85 * a],
        [-0.4 * a, 1.2 * a, -0.85 * a],
        [-0.4 * a, -1.2 * a, -0.85 * a],
        [a, 0.75 * a, -0.85 * a],
        [a, -0.75 * a, -0.85 * a]
    ];
    z_rotations = [ 0, -75, 75, -140, -230 ];
    
    difference() {
        union() {
            difference() {
                // 1. Carve a smaller icosahedron out of the larger one (to make it a box):
                difference() {
                    top_icosahedron(a);
                    top_icosahedron(a-4);
                }
                // 2. Etch out the numbers:
                top_die_with_chars(a, chars);
            }
            
            // 3. Add the magnet pocket supports:
            for(index = [0:4]) {
                translate(translations[index])
                rotate([0, 0, z_rotations[index]])
                magnet_pocket_support_top(a);
            }
        }
        
        // 4. Carve out the magnet pockets:
        for(index = [0:4]) {
            translate(translations[index])
            rotate([0, 0, z_rotations[index]])
            magnet_pocket(a);
        }
    }
}

// A Module that creates a "magnet pocket" for the top of the dice box.
module magnet_pocket_support_top(a = 50) {
    rotate([180, 0, 0])
    cylinder(d1 = a/2, d2 = 2, a/5);
}

// A module that builds the magnet pockets
module magnet_pocket() {
    translate([0, 0, -3])
    cylinder(d=11, d=11, 3);
}

// Creates the bottom of the dice box by doing the following:
// 1. Render the bottom portion of the icosahedron
// 2. Etch (difference) the numbers around the die
// 3. Add the magnet pocket supports
// 4. Carve out the magnet pockets (for 10mm magnets)
module d20_bottom(a = 50, row_1_chars, row_2_chars, row_3_chars) {
    translations = [ 
        [-1.23 * a, 0, -0.85 * a],
        [-0.4 * a, 1.2 * a, -0.85 * a],
        [-0.4 * a, -1.2 * a, -0.85 * a],
        [a, 0.75 * a, -0.85 * a],
        [a, -0.75 * a, -0.85 * a]
    ];
    z_rotations = [ 0, -75, 75, -140, -230 ];
    
    difference() {
        union() {
            difference() {
                // 1. Carve a smaller icosahedron out of the larger one (to make it a box):
                difference() {
                    bottom_icosahedron(a);
                    translate([0, 0, -4])
                    bottom_icosahedron(a-4);
                }
                // 2. Etch out the numbers:
                bottom_die_counter(a, row_1_chars, row_2_chars, row_3_chars);
            }      
          
            // 3. Add the magnet pocket supports:
            for(index = [0:4]) {
                translate(translations[index])
                rotate([0, 0, z_rotations[index]])
                magnet_pocket_support_bottom(a);
            }
        }
        
        // 4. Carve out the magnet pockets:
        for(index = [0:4]) {
            translate(translations[index])
            rotate([0, 0, z_rotations[index]])
            translate([0, 0, 2.99])
            magnet_pocket(a);
        }
    }
}

// The "magnet pockets" for the bottom of the dice box
module magnet_pocket_support_bottom(a = 50) {
   cylinder(d1 = 4*a/6+1, d2 = 5*a/8, a/5);
}

// Displays the top and bottom of the dice box (counter) with a bit of space between them so you can
// see how they fit together.
module display_counter(a = 50) {
    translate([0, 0, -20])
    d20_counter_top(a);
    translate([0, 0, 20])
    d20_counter_bottom(a);
}

// Creates the top of the dice box as a counter:
module d20_counter_top(a = 50) {
    counter_chars = [ "18", "17", "16", "20", "19" ];
    d20_top(a, counter_chars);
}

// Creates the bottom of the dice box as a counter:
module d20_counter_bottom(a = 50) {
    row_1_chars = [ ".9", "7", "15", "13", "11" ];
    row_2_chars = [ "14", "12", "10", "8", "6." ];
    row_3_chars = [ "4", "3", "2", "1", "5" ];
    
    d20_bottom(a, row_1_chars, row_2_chars, row_3_chars);
}


// Displays the top and bottom of the dice box (roller) with a bit of space between them so you can
// see how they fit together.
module display_roller(a = 50) {
    translate([0, 0, -20])
    d20_roller_top(a);
    translate([0, 0, 20])
    d20_roller_bottom(a);
}

// Creates the top of the dice box as a roller:
module d20_roller_top(a = 50) {
    roller_chars = [ "4", "18", "2", "20", "14" ];
    d20_top(a, roller_chars);
}

// Creates the bottom of the dice box as a roller:
module d20_roller_bottom(a = 50) {
    row_1_chars = [ "11", "5", "12", "8", "6." ];
    row_2_chars = [ "10", "16", "9.", "13", "15" ];
    row_3_chars = [ "17", "3", "19", "1", "7" ];
    
    d20_bottom(a, row_1_chars, row_2_chars, row_3_chars);
}

module main() {
    
    // I've determined this to be the approrpiate size:
    // top = 122mm x 129mm x 42 mm (approx)
    // bottom = 136mm x 129mm x 110 mm
    a = 40;
    
    // Display the full die (roller or counter):
    // display_roller(a);
    // display_counter(a);
    
    // Uncomment one of the next 2 lines to render the top of the box (choose roller or counter):
    // rotate([0, 180, 0]) d20_roller_top(a);
    // rotate([0, 180, 0]) d20_counter_top(a);
    
    // Uncomment one of the next two line to render the bottom of the box:
    // d20_roller_bottom(a);
    // d20_counter_bottom(a);
    
    
}


main();
