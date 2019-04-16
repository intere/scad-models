/*****************************************************************
* Twenty Sided Die box, based on the model:
*************************************************************/

/*****************************************************************
* Icosahedron   By Adam Anderson
* 
* This module allows for the creation of an icosahedron scaled up 
* by a factor determined by the module parameter. 
* The coordinates for the vertices were taken from
* http://www.sacred-geometry.es/?q=en/content/phi-sacred-solids
*************************************************************/


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

module top_die_roller(a = 2) {
    chars = ["20", "2", "12", "10", "8" ];
}

module top_icosahedron(a = 2) {
    intersection() {
        rotate([0, 32, 0]) icosahedron(a);
        translate([0, 0, -2.85 * a]) 
        cube(4 * a, center = true);
    }
}

module bottom_icosahedron(a = 2) {
    intersection() {
        rotate([0, 32, 0]) icosahedron(a);
        translate([0, 0, 1.15 * a]) 
        cube(4 * a, center = true);
    }
}

// Creates a nice, thick icosahedron (top section) and then does a diff of the numbers to etch them out.
module d20_top(a = 50) {
    union() {
        difference() {
            difference() {
                top_icosahedron(a);
                top_icosahedron(a-4);
            }
            top_die_counter(a);
        }
        translate([-1.23 * a, 0, -0.91 * a])
        magnet_pocket(a);
        
        translate([-0.4 * a, 1.2 * a, -0.91 * a])
        rotate([0, 0, -75])
        magnet_pocket(a);
        
        translate([-0.4 * a, -1.2 * a, -0.91 * a])
        rotate([0, 0, 75])
        magnet_pocket(a);
        
        translate([a, 0.75 * a, -0.91 * a])
        rotate([0, 0, -140])
        magnet_pocket(a);
        
        translate([a, -0.75 * a, -0.91 * a])
        rotate([0, 0, -230])
        magnet_pocket(a);
    }
}

// Creates a nice, thick icosahedron and then does a diff of the numbers to etch them out.
module d20_bottom(a = 50) {
    union() {
        difference() {
            difference() {
                bottom_icosahedron(a);
                translate([0, 0, -4])
                bottom_icosahedron(a-4);
            }
            bottom_die_counter(a);
        }        

        translate([-1.23 * a, 0, -0.79 * a])
        magnet_pocket_bottom(a);
        
        translate([-0.4 * a, 1.2 * a, -0.79 * a])
        rotate([0, 0, -75])
        magnet_pocket_bottom(a);
        
        translate([-0.4 * a, -1.2 * a, -0.79 * a])
        rotate([0, 0, 75])
        magnet_pocket_bottom(a);
        
        translate([a, 0.75 * a, -0.79 * a])
        rotate([0, 0, -140])
        magnet_pocket_bottom(a);
        
        translate([a, -0.75 * a, -0.79 * a])
        rotate([0, 0, -230])
        magnet_pocket_bottom(a);
    }
}

// A Module that creates a "magnet pocket"
module magnet_pocket(a = 50) {
    
    difference() {
        scale([1.3, 1.36, 1])
        cube([a/3, a/3, 6], center = true);
        cylinder(3, 5.5, 5.5);
        
        scale([1.3, 1.36, 1])
        translate([-a/6, -a/6, -4])
        cylinder(7, a/4);
        
        scale([1.3, 1.36, 1])
        translate([-a/6, a/6, -4])
        cylinder(7, a/4);
    }
}

module magnet_pocket_bottom(a = 50) {    
    rotate([180, 0, 0])
    difference() {
        scale([1.3, 1.36, 1])
        union() {
            cube([a/3, a/3, 6], center = true);
            translate([-a/7, 0, 0])
            cube([a/3, a/3, 6], center = true);
        }
        cylinder(3, 5.5, 5.5);
        
        scale([1.3, 1.36, 1])
        translate([-a/3, -a/6, -4])
        cylinder(15, a/4);
        
        scale([1.3, 1.36, 1])
        translate([-a/3, a/6, -4])
        cylinder(15, a/4);
    }
}

module main() {
    
    translate([0, 0, -20])
    d20_top();
    translate([0, 0, 20])
    d20_bottom();
    //magnet_pocket();
        
    //magnet_pocket_bottom();
}


main();
