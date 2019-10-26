----- Eysile's HousingTools Animation:s -----

# Load animation from a template
/ea load [name]

ie:
/ea load akatosh


# Create an animation from the latest X items piled to the stack
/ea create [name] [X]

ie:
/ea create doors 4


# Add X other keyframes to the stack to an animation at the Y position
/ea replace [name] [X] [Y]

ie:
/ea replace doors 2 3


# Delete an animation
/ea delete [name]

ie:
/ea delete doors


# Empty the item stack
/ea empty


# Set an parameter from an animation
/ea set [name] [variable] [value]

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
/ea set doors ease inoutcubic


# Reset an animation to its beginning
/ea reset [name]

ie:
/ea reset doors


# Play an animation from its beginning
/ea play [name]

ie:
/ea play doors


# Stop a playing animation
/ea stop [name]

ie:
/ea stop doors


# Toggle an animation from the beginning to the end / from the end to the beginning
/ea toggle [name]

ie:
/ea toggle doors


# List animations
/ea list [name / all]

ie:
/ea list all


# Save the scene to the user settings
/ea save


# Reload the scene saved scenes
/ea reload


# Reload the scene
/ea clear
