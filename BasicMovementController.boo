import UnityEngine

class BasicMovementController(MonoBehaviour): 
""" 
A really basic movement Controller, which will move its object in response to 
user Input.  

The controller will move according to the facing of the object. The horizontal
controller input (usually the left and right arrow keys or controller stick
move) will move back and forth on the X-Axis of the controller. The vertical
input (the up/down arrows or stick moves) will move along the local Z axis.

It uses the '[Input](http://docs.unity3d.com/ScriptReference/Input.html)' 
class to read lef/right or front/back movement instead of asking for specific keys.  

Using input this way good idea because it lets you change your mind, or leave the key mappingin the
hands of the user.

Style notes: -----------

	- the  _HORIZ and _VERT variables could just be strings in a real game.
	  Putting them into variables is just protection against typos. 

	- by assinging `1.0` to _Speed, we tell Boo and Unity that _Speed is a numeric value, in
      this case a floating point number.  Usually in boo you can identify variables by just
      putting in a good first value like this. 		
"""
	
	_HORIZ = 'Horizontal'
	_VERT = 'Vertical'
	
	public _Speed = 1.0

	def Update(): 
	""" 
	By assigning frame_speed to <_Speed * Time.deltaTime> we
	make it easy to convert between real-world speeds and the very small numbers
	which Unity will want every frame.   Time.deltaTime is the interval (in
	fractions of a second) since the last frame.  With a speed of 1, the
	Controller will translate at one unit per second; 
	""" 

		frame_speed = _Speed * Time.deltaTime 
		left_right = Input.GetAxis(_HORIZ) * frame_speed
		forward_back = Input.GetAxis(_VERT) * frame_speed
		transform.Translate(Vector3(left_right, 0, forward_back), Space.Self)
