EysilesHousingAnimator.templates = EysilesHousingAnimator.templates or {}
EysilesHousingAnimator.templates["villa"] = { animations = {}, interacts = {} }

EysilesHousingAnimator.templates["villa"].interacts["candle"] = 
{
    ["previousState"] = true,
    ["run"] = 
    {
        [1] = "a toggle gate",
        [2] = "a play gate",
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
            ["z"] = 68229,
            ["pitch"] = 0,
            ["state"] = 0,
            ["yaw"] = 1.9487308264,
            ["name"] = "Candélabre de la Confrérie, table",
            ["id"] = "4616191546495367289",
            ["roll"] = 0,
            ["x"] = 65990,
            ["y"] = 7046,
            ["data_id"] = 3045,
            ["cid"] = 292985,
        },
        ["4616191546495351744"] = 
        {
            ["z"] = 67691,
            ["pitch"] = 0,
            ["state"] = 0,
            ["yaw"] = 1.9517987967,
            ["name"] = "Candélabre de la Confrérie, table",
            ["id"] = "4616191546495351744",
            ["roll"] = 0,
            ["x"] = 65781,
            ["y"] = 7046,
            ["data_id"] = 3045,
            ["cid"] = 277440,
        },
    },
}

EysilesHousingAnimator.templates["villa"].animations["gate"] = 
{
    ["animation"] = "transition",
    ["bounce"] = false,
    ["radius"] = 0,
    ["loop"] = false,
    ["frame"] = 25,
    ["duration"] = 25,
    ["furnitures"] = 
    {
        ["4616191546495351753"] = 
        {
            [2] = 
            {
                ["z"] = 68074,
                ["pitch"] = 0,
                ["state"] = 0,
                ["yaw"] = 1.9222697020,
                ["name"] = "Vitrail de la Confrérie",
                ["id"] = "4616191546495351753",
                ["roll"] = 0,
                ["x"] = 65561,
                ["y"] = 6951,
                ["data_id"] = 3047,
                ["cid"] = 277449,
            },
            [1] = 
            {
                ["z"] = 68071,
                ["pitch"] = 0,
                ["state"] = 0,
                ["yaw"] = 1.9280221462,
                ["name"] = "Vitrail de la Confrérie",
                ["id"] = "4616191546495351753",
                ["roll"] = 0,
                ["x"] = 65578,
                ["y"] = 7502,
                ["data_id"] = 3047,
                ["cid"] = 277449,
            },
        },
    },
    ["durations"] = 
    {
        [2] = 0,
        [1] = 0,
    },
    ["speed"] = 1,
    ["chain"] = "",
    ["rotate"] = true,
    ["plays"] = false,
    ["keyframe"] = 1,
    ["ease"] = "inoutquad",
    ["collectible"] = 0,
}