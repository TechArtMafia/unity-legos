namespace Pathfinding
import UnityEngine
import System
import System.Collections.Generic
import Mathf
import UnityEditor

public class boomap(MonoBehaviour):
	
	public m_start as Vector2
	public m_end as Vector2
			
	public m_map as Map
	public m_results as (Address)
	public m_search as MapSearch
	public m_accuracy = 5
	
	def OnValidate():			
		
		m_search = MapSearch(m_map)
		m_search.m_accuracy = m_accuracy
		result = m_search.search(Address(m_start.x, m_start.y), Address(m_end.x, m_end.y))
		m_results = array(Address, result)
	

			
	def OnDrawGizmosSelected():
		t = gameObject.transform.localToWorldMatrix
		p = gameObject.transform.position
		Gizmos.matrix = transform.localToWorldMatrix
		Gizmos.color = Color.gray
		for x in range(m_map.Width + 1):
			st = Vector3(x, 0, 0)
			en = Vector3(x, 0, m_map.Height)
			Gizmos.DrawLine(st, en)
			
			
		for y in range(0, m_map.Height + 1):
			st = Vector3(0,0, y)
			en = Vector3(m_map.Width, 0, y)
			Gizmos.DrawLine(st, en)
			
		if len(m_results) > 0:
			seg = [Vector3(i.x + .5, 0, i.y + .5) for i in m_results]
			Gizmos.color = Color.red
			for a as Vector3, b as Vector3 in zip(seg, seg[1:]):
				Gizmos.DrawLine (a, b)
			
						
			Gizmos.DrawCube( Vector3(m_end.x + .5, 0, m_end.y + .5), Vector3(.25,.25,.25))
		Gizmos.color = Color.green
		Gizmos.DrawCube( Vector3(m_start.x + .5, 0, m_start.y + .5), Vector3(.25,.25,.25))

[CustomEditor(boomap)]
class MapHandle (Editor):
	
	_x as int
	_y as int
	_v as single
	_pp as Vector3 = Vector3(2,0,2)
	_off as Vector3 = Vector3(.5, 0, .5)
	_selection as Vector3
	
	def OnSceneGUI():
		bm = target as boomap
		go = bm.gameObject
		
		t = go.transform.localToWorldMatrix 
		p = go.transform.position
		Handles.color = Color.yellow
		Handles.matrix = t
		for x in range(bm.m_map.Width):
			for y in range(bm.m_map.Height):
				ad = Address(x, y)
				pos = Vector3(x +0.25 , 0, y + 0.5)
				Handles.Label(pos, bm.m_map.cell_get(ad).ToString())
				if ad in bm.m_search.m_costs:
					pos2 = pos + Vector3(0,0, .25)				
					cost = bm.m_search.m_costs[ad]
					if cost < single.MaxValue:
						Handles.Label(pos2, string.Format("{0:0.0}", cost))
				
				
		bob  = 0.25 cast single
		
		Handles.color = Color(1,1,0,.1)
		_sz = HandleUtility.GetHandleSize(_pp)
		_pp = Handles.Slider2D( _pp, Vector3.right, Vector3.forward, Vector3.right, bob, Handles.SphereCap, Vector2(1,1))
		
		_selection = Vector3(Mathf.RoundToInt(_pp.x - .5), 0 , Mathf.RoundToInt(_pp.z - .5) )
		verts  = ( _selection, _selection + Vector3(0,0,1), _selection + Vector3(1,0, 1), _selection + Vector3(1,0,0)	)
		Handles.DrawSolidRectangleWithOutline(verts, Color(1,1,1,0.2), Color.yellow)

		if HandleUtility.niceMouseDelta == 0:
			_pp = _selection + _off
		
		# todo: maake it modal - double click or key to switch from selection to editing
