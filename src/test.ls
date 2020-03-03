{l,noops} = require "./common"

IS = require "./main"

V1 = IS.array

V2 = V1.continue !-> l "first"


V3 = V2.continue !-> l "second"


V4 = V3.error !-> l "error V3"

# l V3

V4 1

# l V3.continue -> true


