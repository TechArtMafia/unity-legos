import UnityEngine

class JumpingMovementController(MonoBehaviour): 
""" 
This is exactly the same as the BaiscMovementController, except that it adds jumping.	

Jumping requires the controller to keep track of something besides user inputs.  We keep a 
variable called '_Momentum' and when the user hits the jump button we add to the _Momentum.
Then we use that the same way we used the direct key inputs to move the controller. 

To simulate gravity, we subtract from _Momentum at the end of every frame in the LateUpdate()
method.  That slows the jump and then reverse it. To keep the controller from falling 
forever, we check the position of the object each turn and if it is below 0 height, we
zero out the momentum and snap the position to exactly 0.

Note that this is pure fakery - it does not take account of the actual ground or objects
in the scene. But it's a good illustration of how to do it in a simple 2-D world

Style notes
-----------

    - the variable _Momentum is not marked public. Public variables (like
      _Speed) show up in the Inspector.  Since _Momentum is managed by the controller
      itself it does not need to be public (although sometimes it's a good idea to
      make public variables so you can see what's going on while testing) 
	- _Gravity is also not public.  It's always smart to put constants like this 
	  into variables instead of hard-coding them into your scripts -- it makes it 
	  far easier to read the code and also to experiment with changes.

"""
	
	_HORIZ = 'Horizontal'
	_VERT = 'Vertical'
	_JUMP = 'Jump'
	
	public _Speed = 1.0
	public _JumpSpeed = 1.5

	_Momentum = 0.0
	_Gravity = 2

	def Update(): 
	""" 
	Moves on the 2-d plane like BaiscMovementController, but if users presses the jump
	input we add upward momentum
	""" 
		frame_speed = _Speed * Time.deltaTime 

		# only allow jumps if we are on the ground!
		if transform.position.y == 0 :
			_Momentum += Input.GetAxis(_JUMP) * _JumpSpeed

		up =  _Momentum * Time.deltaTime
		left_right = Input.GetAxis(_HORIZ) * frame_speed
		forward_back = Input.GetAxis(_VERT) * frame_speed

		transform.Translate(Vector3(left_right, up, forward_back), Space.Self)

	def LateUpdate():
	"""
	If the unit is in the air, deduct some momentum. If it is below the ground,
	zero out both momentum and the height so we don't fall through the floor
	"""
		if transform.position.y > 0:
			_Momentum -= _Gravity * Time.deltaTime;
		else:
			_Momentum = 0;
			vp = Vector3(transform.position.x, 0, transform.position.z)
			transform.position = vp