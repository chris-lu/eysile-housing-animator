----- Eysile's Housing Animator -----

# Load animation from a template
/eha a load [name]
ie:
/eha a load arene


# Create an animation from the latest X items piled to the stack
/eha a create [name] [X]
ie:
/eha a create doors 4


# Add X other keyframes to the stack to an animation at the Y position
/eha a replace [name] [X] [Y]
ie:
/eha a replace doors 2 3


# Delete an animation
/eha a delete [name]
ie:
/eha a delete doors


# Set an parameter from an animation
/eha a set [name] [variable] [value]

* [variable] could be:
  trigger [ID]       The ID of a collectible to play when playing / toggling the animation
  loop [0/1]         Auto loop the nimation
  bounce [0/1]       Revert play the animation when finished
  rotate [0/1]       Rotate the items to their new pitch, yaw, roll while moving
  ease [ease]        Ease function to calculate position
  duration [X]       Duration of the animation
  durations [X] [Y]  Duration for the keyframe Y
  speed [x.xx]       Speed of the animation
  
* [ease] could be:  
  linear, inquad, outquad, inoutquad, outinquad, incubic, outcubic, inoutcubic, outincubic, inquart, outquart, 
  inoutquart, outinquart, inquint, outquint, inoutquint, outinquint, insine, outsine, inoutsine, outinsine, 
  inexpo, outexpo, inoutexpo, outinexpo, incirc, outcirc, inoutcirc, outincirc, inelastic, outelastic, 
  inoutelastic, outinelastic, inback, outback, inoutback, outinback, outbounce, inbounce, inoutbounce, outinbounce
ie:
/eha a set doors ease inoutcubic


# Reset an animation to its beginning
/eha a reset [name]
ie:
/eha a reset doors


# Play an animation from its beginning
/eha a play [name]
ie:
/eha a play doors


# Stop a playing animation
/eha a stop [name]
ie:
/eha a stop doors


# Toggle an animation from the beginning to the end / from the end to the beginning
/eha a toggle [name]
ie:
/eha a toggle doors


# List animations
/eha a list [name / all]

ie:
/eha a list all

# Activate objects
/eha a activate light off
/eha a activate light on

# Create a trigger
/eha t create [name]
ie:
/eha t create switch

# Create a trigger
/eha t create [name]
ie:
/eha t create switch

# Set an parameter from a trigger
/eha t set [name] [variable] [value]

* [variable] could be:
  run [command] [1-9]      Define a EHA command to trigger when the object reach the state "nr"
ie:
/eha t set switch run activate+gate+off 1
/eha t set switch run activate+gate+on 2

# Empty the item stack
/eha empty

# Save the scene to the user settings
/eha save

# Reload the scene saved scenes
/eha reload

# Reload the scene
/eha clear
