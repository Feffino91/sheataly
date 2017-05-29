/**
* Name: sheataly
* Author: rugantio
* Description: -
* Tags: 
*/

model grid_setup

global{
	int l_cell <- 15; //Lenght of the grid
	int w_cell <- 15; // Width of the grid
	int tables <- 5; // Tables are both targets and walls, they are created randomly in the plot
	int wall <- 5;
	int num_waiters <- 5;
	
	init{	
		ask tables among plot{ //Spawn tables 
			cover <- "table";
			color <- #black;
		}
		ask wall among plot{   //Spawn walls
			cover <- 'wall';
			color <- #red;
		}
/* 		loop i from:0  to: int(w_cell/2){ //Spawns walls by user
			ask (plot where ((each.grid_x = i) and (each.grid_y = 3))) {
				cover <- "barrier";
				color <- #red;				
			}cell
		}
	*/	ask plot{            //When plot is called....
			neigh <- (self neighbors_at 1) where (each.cover != "wall" and each.cover != "table"); //List neigh is an aspect relative to a cell, it defines possible new movements 
		}																						   
		
		list<plot> nextCell <- plot where (each.cover = "table"); // Defines a list of forthcoming cells, calling plot only for table cells
		int dist <- 0;
		
		loop while: !empty(nextCell) { //goes around all the possible cells and changes attributes accordingly
				//rgb r_color <- rnd_color(255); //changes color of a target cell
				ask nextCell{     //for every possible next cell we ask to set distance (from a table)
				distance <- dist; //  set distance to dist (initially set to 0, gets increased every cycle)
				//color <- r_color;      //change color of the cell (initially 255)...
				}
				list<plot> neighs <- remove_duplicates(nextCell accumulate (each.neigh)); //Neighs is a temporary list variable which stores all the neighbors of the current cell
				nextCell <- neighs where (each.distance = -1);   //Next cells to evaluate are all the cells with distance greater than current one from the table
				dist <- dist + 1; 
		}					 
		create waiter number: num_waiters { //Spawns waiters randomly
			my_cell <- one_of(plot where (each.cover != "barrier" and each.cover != "table")); //waiter is to be put on a random square of the grid
			location <- my_cell.location;
		}
	}
}

species waiter {
	plot my_cell; //	my_cell is a plot attribute for the species 
	reflex get_order when: (my_cell.distance > 1){		
		plot next_plot <- my_cell.neigh with_min_of(each.distance); //Next cell to 	go is the one closest to a table
		my_cell <- next_plot;
		location <- my_cell.location;
		}
	aspect base {
		draw circle(1) color: #blue;
	}
}

grid plot height: l_cell width: w_cell neighbors:4 {
	string cover <- "free";
	rgb color <- #white;
	int distance <- -1;
	list<plot> neigh <- [];
}

experiment restaurant type: gui{
	parameter "Grid Length:" var:l_cell min: 5 max: 30 category:"Grid";
	parameter "Grid Width:" var:w_cell min: 5 max: 30 category:"Grid";
	parameter "Number of obstacles:" var:wall min: 1 max: 15 category:"Grid";
	parameter "Number of waiters:" var:num_waiters min: 1 max: 15 category:"Agents";
	parameter "Number of tables:" var:tables min: 1 max: 15 category:"Agents";
	output{
		display simulation{
			grid plot lines: #black ;
			species waiter aspect: base;
			}
	}
}

