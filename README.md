----- Eysile's Housing Animator -----

# Load animation from a template
/eha load [name]

ie:
/eha load akatosh


# Create an animation from the latest X items piled to the stack
/eha create [name] [X]

ie:
/eha create doors 4


# Add X other keyframes to the stack to an animation at the Y position
/eha replace [name] [X] [Y]

ie:
/eha replace doors 2 3


# Delete an animation
/eha delete [name]

ie:
/eha delete doors


# Empty the item stack
/eha empty


# Set an parameter from an animation
/eha set [name] [variable] [value]

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
/eha set doors ease inoutcubic


# Reset an animation to its beginning
/eha reset [name]

ie:
/eha reset doors


# Play an animation from its beginning
/eha play [name]

ie:
/eha play doors


# Stop a playing animation
/eha stop [name]

ie:
/eha stop doors


# Toggle an animation from the beginning to the end / from the end to the beginning
/eha toggle [name]

ie:
/eha toggle doors


# List animations
/eha list [name / all]

ie:
/eha list all


# Save the scene to the user settings
/eha save


# Reload the scene saved scenes
/eha reload


# Reload the scene
/eha clear
