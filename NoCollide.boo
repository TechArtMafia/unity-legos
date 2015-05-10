import UnityEngine
import System.Collections.Generic


class Rota[of T]:

	_storage as (T)
	_capacity = 0
	_pointer = 0

	def constructor( length as int):
		_storage = array[of T](length)
		_capacity = length
		_pointer = 0

	def Add(obj as T):
		if _pointer < _capacity:
			_storage[_pointer] = obj
			_pointer += 1
			return

		for idx as int, val as T in enumerate(_storage[1:]):
			_storage[idx] =val
		_storage[_capacity -1] = obj

	def Values():
		return _storage




class NoCollide(MonoBehaviour):
"""
Watch for all move changes on this object, then unwind any moves if the object collides Rect.with
something else.
"""

	_previous_turn = Rota[of Vector3](4)
	_collisions = List[of Collision]()

	def Start():
		_previous_turn.Add(transform.position)

	
	def OnCollisionEnter(coll as Collision):
		_collisions.Add(coll)
		#Debug.Log(coll)

	def OnCollisionStay(coll as Collision):
		_collisions.Add(coll)

	def LateUpdate():
		if len(_collisions):
			transform.position = _previous_turn.Values()[0]
			_collisions.Clear()
		
		_previous_turn.Add(transform.position)