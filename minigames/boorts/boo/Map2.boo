namespace Pathfinding
import UnityEngine
import System
import System.Collections.Generic
import Mathf
import UnityEditor

[Serializable]
public enum MapType:
	empty = 0
	hills = 1
	water = 2


[Serializable]
public class SerializableMap:
"""
2-D array of cells connected by edges. 

Cells and Edges can both have costs (by default an edge cost )
"""

	[SerializeField]
	width as int = 1

	[SerializeField]	
	height as int = 1
	
	[SerializeField]
	cells as (int) = (0,)

	public Size:
		get:
			return width * height

	public Width:
		get:
			return width
		set:
			if value != width:
				old_u = width
				width = value
				Rebuild(old_u, height)

	public Height:
		get:
			return height
		set: 
			if value != height:
				old_v = height
				height = value
				Rebuild(width, old_v)

	def Rebuild(old_u as int, old_v as int):
		new_u = Width
		new_v = Height
		new_cells = array(int, new_u * new_v)
		for u in range(new_u):
			for v in range(new_v):
				if cells != null and u < old_u and v < old_v:
					old_val = cell_get(cells, old_u, u, v)
					cell_set (new_cells, new_u, u, v, old_val)
		cells = new_cells

	static def  cell_get( _cells as (int), width as int, u as int, v as int):
		return _cells[(v * width) + u]

	static def cell_set (_cells as (int), width as int, u as int, v as int, val as int):
		_cells[(v * width) + u] = val

	public self[u as int, v as int] as int:
		get:
			return cell_get(cells, width, u, v)
			
		set:
			cell_set (cells, width, u, v, value)
			



public class Map2(ScriptableObject):
	

	[SerializeField]
	m_map as SerializableMap = SerializableMap()


	public Width as int:
		get:
			return m_map.Width
		set:
			m_map.Width = value
			
	public Height as int:
		get:
			return m_map.Height
		set: 
			m_map.Height = value

	public self[u as int, v as int] as int:
		get:
			return m_map[u, v]
			
		set:
			m_map[u, v] = value

	public def neighborhood(u as int, v as int) as (int)*:
		min_u = Mathf.Max(0, u - 1)
		min_v = Mathf.Max(0, v - 1)
		max_u = Mathf.Max(Width - 1, u + 1)
		max_v = Mathf.Max(Height -1, v + 1)
		for uu in (min_u, u, max_u):
			for vv in (min_v, v, max_v):
				if (uu, vv) != (u, v):
					yield (uu, vv)