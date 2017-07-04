local Lattice = require 'Lattice'
local MyLattice = Lattice:New();

math.randomseed(os.time())

local Model = require 'Model';
Model = Model:New();
Model.Lattice = MyLattice;

MyLattice:Init(10,10,1);
MyLattice:InitRandomField(8,0);
MyLattice.J = 2;
-- If you want to calculate resistances, also init the RN;

MyLattice:InitRN();

local vol = MyLattice.x * MyLattice.y * MyLattice.z

function Model:Measure(Lattice)
	-- Return a table where [ylabel] = measuredpoint.
	local Out = {};

	Out.M = (Lattice:GetM()/vol + 1)/2;

	return Out;
end 






local function linspace(startn,num,endn)
	local step = (endn-startn) / (num-1);
	local out = {}

	for i = 1, num do 
		local val = startn + (i-1)*step 
		table.insert(out, val) 
	end 
	return out
end ;

local function tjoin(t1, t2)
	local out = {};
	for i,v in pairs(t1) do
		table.insert(out,v)
	end 
	for i,v in pairs(t2) do 
		table.insert(out,v)
	end 
	return out ;
end 

local mul = 1

--[[local Field = linspace(-3*mul,450/2,1.5*mul);
local Field2 = linspace(1.5*mul,200/2,-0.5*mul);
local Field3 = linspace(-0.5*mul,350/2,3*mul);
local Field4 = linspace(3*mul,450/2,-1.5*mul);
local Field5 = linspace(-1.5*mul,200/2,0.5*mul);
local Field6 = linspace(0.5*mul,350/2,-3*mul);

local Field = tjoin(Field,Field2);
local Field = tjoin(Field,Field3);
local Field = tjoin(Field,Field4);
local Field = tjoin(Field,Field5);
local Field = tjoin(Field,Field6);--]]

for x = 1, 10 do 
    MyLattice.Grid[x][5][1].Spin=1;
end 

local R = MyLattice.RN:GetEdgeResistance();
print(R)
MyLattice:Dump("tmp.lat")
for x = 1, 10 do 
    MyLattice.Grid[x][5][1].Spin=-1;
end 
for y = 1, 10 do 
    MyLattice.Grid[5][y][1].Spin=1;
end 
local R = MyLattice.RN:GetEdgeResistance();
print(R)
MyLattice:Dump("tmp.lat")

os.exit()

local Plotter = require 'Plotter';

local gp = require'lgnuplot'

local M = DataOut.ExternalField.M.y;

local Temperature = DataOut.ExternalField.M.x;

local TempUp = {};
local TempDown = {};

MUp = {};
MDown = {};

local using = TempUp;
local using2 = MUp;
local old = -1000
for i,v in pairs(Temperature) do 
	if v < old then 
		using = TempDown
		using2 = MDown;
		old = v;
	elseif v >= old then 
		old = v 
		using = TempUp;
		using2 = MUp;
	end 
	table.insert(using, v);
	table.insert(using2, M[i])
end 




local g = gp{    
	width  = 640,
    height = 480,
    xlabel = "Time",
    ylabel = "Volume fraction metal",
    key    = "bmargin left horizontal Right noreverse enhanced autotitle box lt black linewidth 1.000 dashtype solid",
    terminal = "png";
    ["title  font"] = "\",20\"";
    title = "Volume fraction metal a function of field";

    data = {
           	
       
    gp.array {  -- plot from an 'array-like' thing in memory. Could be a
                    -- numlua matrix, for example.
            {
              	TempUp,
              	MUp
            },
            
            title = "Increasing field",          -- optional
            using = {1,2},              -- optional
    		ptype = 9;
    		psize = 1;
    		linewidth = 0;

   
        },
    gp.array {  -- plot from an 'array-like' thing in memory. Could be a
                    -- numlua matrix, for example.
            {
              	TempDown,
              	MDown
            },
            
            title = "Decreasing field",          -- optional
            using = {1,2},              -- optional
    		ptype = 11;
    		psize = 1;
    		linewidth = 0;
   
        },

        
 --[[       gp.func {   -- plot from a Lua function
            function(x)                 -- function to plot
                return 3* math.sin(2*x) + 4
            end,
            
            range = {-2, 10, 0.01},     -- optional
            width = 3,                  -- optional
            title = '3sin(2x) + 4',     -- optional
            with  = 'lines',
        },
        
        gp.gpfunc { -- plot from a native gnuplot function
            "gamma*sin(1.8*x) + 3",
            width = 2,
            title = 'gamma sin(1.8x) + 3',
        },--]]
        

    }    
}:plot('output.png')

