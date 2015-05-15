import UnityEngine
import System


class rocket (MonoBehaviour): 

	public _Engine as Engine
	public _Hover as Hover
	public _Rudder as Rudder
	public _Brakes as Brake
	public _Stabilizer as Stabilizer
	
	public _Throttle = 0.0
	public _Steering as double = 0.0
	public _Braking = 0.0
	
	
	def Start ():
		for comp in (_Engine, _Rudder, _Hover, _Brakes, _Stabilizer):
			comp.Setup(gameObject)
			
	def FixedUpdate():
		_Stabilizer.Update()
		_Engine.Update(_Throttle)
		_Hover.Update()
		_Rudder.Update(_Steering)
		_Brakes.Update(_Braking)
		
	def Update ():
		_Throttle = Input.GetAxis("Vertical")
		_Steering = Input.GetAxis("Horizontal")
		_Braking = Input.GetAxis("Jump")


	def OnDrawGizmos():
		_Stabilizer.Draw()
		
[System.Serializable]
class SubComponent:
	
	_xform as UnityEngine.Transform
	_rigid as UnityEngine.Rigidbody
	
	virtual def Setup(gameobj as GameObject):
		_xform = gameobj.transform
		_rigid = gameobj.GetComponent(typeof(UnityEngine.Rigidbody))
		

class Engine(SubComponent):
	
	public _Thrust = 100.0
	
	_Integrity = 1.0
	
	def Update(throttle as single):
		_rigid.AddRelativeForce(Vector3.forward * _Integrity * _Thrust * throttle * Time.fixedDeltaTime)

	
class Hover(SubComponent):
	
	public _Thrust = 100.0
	public _Ceiling = 2.0
	
	# @todo:  use a gri of sample points
	_Integrity = 1.0
	
	def Update():
		ground_effect =  Mathf.Pow(1.0 - Mathf.Clamp01(_xform.position.y / _Ceiling), 2)
		verticality = Vector3.Dot(_xform.up, Vector3.up)
		_rigid.AddRelativeForce(Vector3.up * (_Integrity * _Thrust * Time.fixedDeltaTime * ground_effect * verticality))
		

class Rudder(SubComponent):
	
	public _Torque = 1.0
	public _Lean = .1
	
	_Integrity = 1.0
		
	def Update(steer as double):
		roll = Vector3.forward * steer * _Lean * -1
		twist = Vector3.up * steer

		_rigid.AddRelativeTorque( (roll + twist) * _Torque  * Time.fixedDeltaTime)
		

		

class Stabilizer(SubComponent):
	
	public _Width = 2.0
	public _Length = 2.0
	public _Offset = 1.0
	public _Depth_Test = 1.5
	
	public _Stability = 1
	public _Side_Thrust = 10
	
	_Test_Points = array(Vector4, (Vector4(-1,-1,-1, 1), Vector4(-1,-1,1,1), Vector4(1,-1,1,1), Vector4(1,-1,-1,1)))
	_penetration as single
	_test_points = array(Vector4, (Vector4(-1,-1,-1, 1), Vector4(-1,-1,1,1), Vector4(1,-1,1,1), Vector4(1,-1,-1,1)))

	override def Setup(g as UnityEngine.GameObject):
		_xform = g.transform
		_rigid = g.GetComponent(typeof(UnityEngine.Rigidbody))
		
		roll_points = (_Width / 2.0, 0, _Width / -2.0)
		pitch_points = (_Length / 2.0, 0, _Length / -2.0)	
		def sample(a as single, b as single):
			return Vector4(a, -.5 * _Offset, b, 1)
			
		_Test_Points = array (Vector4, [sample(x, z) for x in roll_points for z in pitch_points])
		
				
	def Update():
		
		for p in _Test_Points:
			_test_point = _xform.localToWorldMatrix * p
			_penetration = Mathf.Pow(Mathf.Clamp01( (_test_point.y * -1) / _Depth_Test), 2)
			if _penetration > 0:
				_rigid.AddForceAtPosition(Vector3.up * _Stability * _penetration * Time.fixedDeltaTime, _test_point)
		
	def Draw():
		for p in _Test_Points:
			_test_point = _xform.localToWorldMatrix * p
			Gizmos.DrawLine(_xform.position, _test_point);

class Brake(SubComponent):
	
	public BrakingForce = 1.0
	
	# maybe want to separate side-slip from front-back?
	
	def Update(brake as single):
		if brake > 0.01:
			
			relative_v = _rigid.velocity * -1
			relative_t = _rigid.angularVelocity * -1
			_rigid.AddTorque(relative_t * BrakingForce * Time.fixedDeltaTime)
			_rigid.AddForce(relative_v * BrakingForce * Time.fixedDeltaTime)
		
	