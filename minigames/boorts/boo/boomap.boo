import UnityEngine
import System.Collections.Generic
import Mathf

public class Address(IComparable):
"""
Immutable x, y address
"""
	public x as int
	public y as int

	def constructor(X as int, Y as int):
		x = X
		y = Y
		
	override def ToString():
		return string.Format("({0},{1})", x, y)
		
	override def GetHashCode():
		return ToString().GetHashCode()

	override def Equals(other):
		comp = other as Address
		if not comp:
			return false
		return comp.x == x and comp.y == y

		
	def CompareTo(other):
		return GetHashCode().CompareTo(other.GetHashCode())
		
				
	def dist(other as Address):
		dx = other.x - x
		dy = other.y - y
		return Mathf.Sqrt( Mathf.Pow(dx, 2) + Mathf.Pow(dy, 2))


public class OpenList:
"""
Sorted list of Addresses.  Pops highest weights first
"""
	m_list as SortedList[of Address, single]

	def constructor():
		m_list = SortedList[of Address, single]()

	count as int:
		get:
			return m_list.Count

	def pop():
		result = m_list.Keys[0]
		m_list.RemoveAt(0 )
		return result

	def add( weight as single, addr as Address):
		if addr in m_list:
			m_list.Remove(addr)
		m_list.Add( addr, weight )




public class Edge (IComparable):
"""
From > To address pair
"""
	public start as Address
	public end as Address

	def constructor(from_address as Address, to_address as Address):
		start = from_address
		end = to_address

	def constructor(x1 as int, y1 as int, x2 as int, y2 as int):
		start =  Address(x1, y1)
		end  =  Address(x2, y2)

	override def ToString():
		return string.Format("{0},{1}", start, end)

	override def GetHashCode():
		return ToString().GetHashCode()
		
	override def Equals(other):
		comp = other as Edge
		if not comp:
			return false
		return comp.start == start and comp.end == end
		
	def CompareTo(other):
		return GetHashCode().CompareTo(other.GetHashCode())

public class WeightedLink:
"""
bundle a destination, weight pair
"""
	public address as Address
	public weight as single

	def constructor(addr as Address, w as single):
		address = addr
		weight = w


public class Map:

	public x_size as int
	public y_size as int
	public m_cells as Dictionary[of Address, single]
	public m_edges as Dictionary[of Edge, single]

	public cell_count:
		get:
			return x_size * y_size

	public def constructor( width as int, height as int):
		x_size = width
		y_size = height

		m_cells = Dictionary[of Address, single]()
		m_edges = Dictionary[of Edge, single]()
		addresses = (Address(x,y) for x in range(x_size) for y in range(y_size))
		
		for addr in addresses:
			m_cells[addr] = 1.0
			for conn in connections(addr):
				m_edges[Edge(addr, conn)] = addr.dist(conn)


	def connections(addr as Address):
		valid_x = { t as Address | t.x > -1 and t.x < x_size}
		valid_y = { t as Address | t.y > -1 and t.y < y_size}
		is_valid = { t as Address | t != addr and valid_x(t) and valid_y(t) }

		for x_offset in (-1, 0, 1):
			for y_offset in (-1,0, 1):
				test_addr = Address(addr.x + x_offset, addr.y + y_offset)
				if is_valid(test_addr):
					yield test_addr

	def links(addr as Address):
	"""
	return the edge cost and the cell cost for all of the neighbors of addre
	"""
		for conn in connections(addr):
			yield WeightedLink(conn, m_edges[Edge(addr, conn)] + m_cells[conn])

	def cell_set(addr as Address, cell as single):
		m_cells[addr] = cell

	def cell_get(addr as Address):
		return m_cells[addr]

	def edge_set (edge as Edge, cost as single):
		m_edges[edge] =cost

	def edge_get(edge as Edge):
		return m_edges[edge]


public class MapSearch:

	m_OpenList as OpenList
	m_map as Map
	m_links as Dictionary[of Address, Address]

	public m_costs as Dictionary[of Address, single]
	public m_accuracy = 5
	public m_steer = 1

	def constructor(map_data as Map):
		m_map = map_data
		m_OpenList = OpenList()
		m_links = Dictionary[of Address, Address]()
		m_costs = Dictionary[of Address, single]()


	def search(start as Address, end as Address):

		m_costs.Clear()
		m_links.Clear()
		m_OpenList = OpenList()
		m_costs[start] = -1.0
		m_links[start] = start
		m_OpenList.add(0.0, start) 

		found = single.MaxValue
		found_count = 0

		while m_OpenList.count > 0 and found_count < m_accuracy:
			current_node = m_OpenList.pop() 
			cost_to_here = m_costs[current_node]

			for weightedLink in m_map.links(current_node):
				next_link = weightedLink.address
				next_cost = weightedLink.weight

				if  next_link not in m_costs:
					m_costs[next_link] = single.MaxValue
				
				node_cost = m_costs[next_link]
				predicted_cost = cost_to_here + next_cost 

				if next_link == end:	
					found = Mathf.Min(found, predicted_cost)
					found_count += 1

				if predicted_cost < node_cost and predicted_cost < found:
					guess_cost =  heuristic(next_link, end)
					m_OpenList.add(	guess_cost, next_link)# does this sort right?
					m_links[next_link] = current_node
					m_costs[next_link] = predicted_cost

		if found == single.MaxValue:
			return List[of Address]()

		return recurse_path(start, end)

	def recurse_path(st as Address, node as Address):	
		result = List[of Address]()
		prev = node
		result.Add(node)
		while prev != st:
			prev = m_links[prev] 
			result.Add(prev)	

		return result


	def heuristic(current as Address, end as Address):
		return current.x
		return Vector2.Distance(Vector2(end.x, end.y) ,Vector2(current.x, current.y)) *  m_steer

public class boomap(MonoBehaviour):
	
	public m_width = 10
	public m_height = 10
	public m_start as Vector2
	public m_end as Vector2
			
	public m_map as Map
	public m_results as (Address)
	public m_search as MapSearch
	public m_accuracy = 5
	public m_steer = 1
	
	def OnValidate():
		m_map = Map(m_width, m_height)
		m_search = MapSearch(m_map)
		m_search.m_accuracy = m_accuracy
		m_search.m_steer = m_steer
		result = m_search.search(Address(m_start.x, m_start.y), Address(m_end.x, m_end.y))
		m_results = array(Address, result)
	

			
	def OnDrawGizmosSelected():
		t = gameObject.transform.localToWorldMatrix
		p = gameObject.transform.position
		Gizmos.matrix = transform.localToWorldMatrix
		Gizmos.color = Color.gray
		for x in range(m_map.x_size + 1):
			st = Vector3(x, 0, 0)
			en = Vector3(x, 0, m_map.y_size)
			Gizmos.DrawLine(st, en)
			
			
		for y in range(0, m_map.y_size + 1):
			st = Vector3(0,0, y)
			en = Vector3(m_map.x_size, 0, y)
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
	
	def OnSceneGUI():
		bm = target as boomap
		go = bm.gameObject
		t = go.transform.localToWorldMatrix
		p = go.transform.position
		Handles.color = Color.yellow
		Handles.matrix = t
		for x in range(bm.m_map.x_size):
			for y in range(bm.m_map.y_size):
				ad = Address(x, y)
				pos = Vector3(x +0.25 , 0, y + 0.5)
				#Handles.Label(pos, ad.ToString())
				if ad in bm.m_search.m_costs:
					pos2 = pos + Vector3(0,0, .25)				
					cost = bm.m_search.m_costs[ad]
					if cost < single.MaxValue:
						Handles.Label(pos2, string.Format("{0:0.0}", cost))
				#c2 = Handles.Slider(pos2, Vector3.up, cost, Handles.ArrowCap, .01 ).z
				#f GUI.changed:
				#	bm.m_map.cell_set(ad, c2)
				#	SceneView.RepaintAll()
				#	Debug.Log(c2)

				
