EysilesHousingAnimator.templates = EysilesHousingAnimator.templates or {}
EysilesHousingAnimator.templates["moon"] = { animations = {}, interacts = {} }

EysilesHousingAnimator.templates["moon"].animations["door"] = 
{
    ["durations"] = 
    {
        [1] = 0,
        [2] = 0,
    },
    ["ease"] = "inoutquad",
    ["loop"] = false,
    ["duration"] = 25,
    ["chain"] = "",
    ["speed"] = -1,
    ["furnitures"] = 
    {
        ["4616191546495351753"] = 
        {
            [1] = 
            {
                ["x"] = 123874,
                ["cid"] = 277449,
                ["pitch"] = 0,
                ["id"] = "4616191546495351753",
                ["name"] = "Vitrail de la Confrérie",
                ["yaw"] = -1.5832599401,
                ["y"] = 11176,
                ["z"] = 75114,
                ["state"] = 0,
                ["roll"] = 0,
                ["data_id"] = 3047,
            },
            [2] = 
            {
                ["x"] = 123849,
                ["cid"] = 277449,
                ["pitch"] = 0,
                ["id"] = "4616191546495351753",
                ["name"] = "Vitrail de la Confrérie",
                ["yaw"] = -1.5775073767,
                ["y"] = 10539,
                ["z"] = 75109,
                ["state"] = 0,
                ["roll"] = 0,
                ["data_id"] = 3047,
            },
        },
    },
    ["frame"] = 0,
    ["animation"] = "transition",
    ["keyframe"] = 1,
    ["bounce"] = false,
    ["plays"] = false,
    ["rotate"] = true,
    ["collectible"] = 0,
    ["radius"] = 0,
}

EysilesHousingAnimator.templates["moon"].interacts["candles"] = 
{
    ["run"] = 
    {
        [1] = "a toggle door",
        [2] = "a play door",
        [3] = "",
        [4] = "",
        [5] = "",
        [6] = "",
        [7] = "",
        [8] = "",
        [9] = "",
    },
    ["furnitures"] = 
    {
        ["4616191546495367289"] = 
        {
            ["x"] = 123710,
            ["cid"] = 292985,
            ["pitch"] = 0,
            ["id"] = "4616191546495367289",
            ["name"] = "Candélabre de la Confrérie, table",
            ["yaw"] = -1.5788496733,
            ["y"] = 10864,
            ["z"] = 75432,
            ["state"] = 0,
            ["roll"] = 0,
            ["data_id"] = 3045,
        },
        ["4616191546495368732"] = 
        {
            ["x"] = 123710,
            ["cid"] = 294428,
            ["pitch"] = 0,
            ["id"] = "4616191546495368732",
            ["name"] = "Candélabre de la Confrérie, table",
            ["yaw"] = -1.5984081030,
            ["y"] = 10865,
            ["z"] = 74789,
            ["state"] = 0,
            ["roll"] = 0,
            ["data_id"] = 3045,
        },
    }
}
