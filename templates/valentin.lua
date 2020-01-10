EysilesHousingAnimator.templates = EysilesHousingAnimator.templates or {}
EysilesHousingAnimator.templates["valentin"] = { animations = {}, interacts = {} }


EysilesHousingAnimator.templates["valentin"].animations["sphere"] = 
{
	["durations"] = 
	{
		[1] = 0,
		[2] = 0,
		[3] = 0,
		[4] = 0,
		[6] = 0,
	},
	["bounce"] = false,
	["radius"] = 0,
	["chain"] = "",
	["furnitures"] = 
	{
		["4780423098665153585"] = 
		{
			[1] = 
			{
				["id"] = "4780423098665153585",
				["state"] = 0,
				["cid"] = 144433,
				["pitch"] = 0,
				["y"] = 29103,
				["x"] = 37882,
				["z"] = 37928,
				["yaw"] = 0,
				["roll"] = 0,
			},
			[2] = 
			{
				["id"] = "4780423098665153585",
				["y"] = 29103,
				["x"] = 37882,
				["z"] = 37928,
				["state"] = 0,
				["cid"] = 144433,
				["pitch"] = 0,
				["yaw"] = 1.570796,
				["roll"] = 0,
			},
			[3] = 
			{
				["id"] = "4780423098665153585",
				["y"] = 29103,
				["x"] = 37882,
				["z"] = 37928,
				["state"] = 0,
				["cid"] = 144433,
				["pitch"] = 0,
				["yaw"] = 3.14159265,
				["roll"] = 0,
			},
			[4] = 
			{
				["id"] = "4780423098665153585",
				["state"] = 0,
				["cid"] = 144433,
				["pitch"] = 0,
				["y"] = 29103,
				["x"] = 37882,
				["z"] = 37928,
				["yaw"] = 4.71238898,
				["roll"] = 0,
			},
			[5] = 
			{
				["id"] = "4780423098665153585",
				["state"] = 0,
				["cid"] = 144433,
				["pitch"] = 0,
				["y"] = 29103,
				["x"] = 37882,
				["z"] = 37928,
				["yaw"] = 6.28318530717,
				["roll"] = 0,
			},
		},
	},
	["loop"] = true,
	["collectible"] = 0,
	["frame"] = 0,
	["keyframe"] = 1,
	["speed"] = 1,
	["plays"] = true,
	["duration"] = 60,
	["rotate"] = true,
	["ease"] = "linear",
	["animation"] = "transition",
}

EysilesHousingAnimator.templates["valentin"].animations["gate"] = 
{
  ["bounce"] = false,
  ["animation"] = "transition",
  ["collectible"] = 0,
  ["keyframe"] = 1,
  ["chain"] = "",
  ["plays"] = false,
  ["durations"] = 
  {
      [1] = 0,
  },
  ["loop"] = false,
  ["rotate"] = true,
  ["radius"] = 0,
  ["frame"] = 0,
  ["speed"] = 1,
  ["duration"] = 1,
  ["ease"] = "inoutquad",
  ["furnitures"] = 
  {
      ["4780423098665156907"] = 
      {
          [1] = 
          {
            ["roll"] = 0,
            ["x"] = 40006,
            ["z"] = 39798,
            ["state"] = 1,
            ["y"] = 21282,
            ["pitch"] = 1.5621645451,
            ["id"] = "4780423098665156907",
            ["cid"] = 147755,
            ["yaw"] = -1.7943743467,
          },
      },
  }
}

EysilesHousingAnimator.templates["valentin"].interacts["cristal"] = 
{
	["furnitures"] = 
	{
		["4717314781953096592"] = 
		{
			["roll"] = 0,
			["x"] = 39627,
			["yaw"] = 1.2701361179,
			["y"] = 21145,
			["cid"] = 228240,
			["pitch"] = 0,
			["id"] = "4717314781953096592",
			["state"] = 0,
			["z"] = 39993,
		},
	},
	["commands"] = 
	{
		[1] = "a activate gate on",
		[2] = "a activate gate off",
		[3] = "",
		[4] = "",
		[5] = "",
		[6] = "",
		[7] = "",
	},
}
