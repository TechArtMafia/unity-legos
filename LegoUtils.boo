"""
This file contains generic functions and classes (not Components!) that are used in other legos. To use in other scripts, just 'import legos' and use, or call as legos.function_or_class
"""
namespace legos
import  UnityEngine
import System
import System.Collections.Generic


class LegoUtils(MonoBehaviour):
"""
this is a Dummy monobehavior, it exists only so we have a single file to share
common library functions
"""
	__version__ = (0,1)

	def Start():
		raise Exception("This component is a stub, don't attach it to game objects")


class Rota[of T]:
"""
This class maintains a 
"""

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
