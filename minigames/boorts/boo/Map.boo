namespace Pathfinding
import UnityEngine
import System
import System.Collections.Generic
import Mathf
import UnityEditor

[Serializable]
public class Cell:

	static public final cost = 1.0
	static final name = "empty"

public class Hills (Cell):

	override static public final cost = 2.5
	override static public final name = "hills"



[Serializable]
public class Address:
"""
hashable X,Y 2d address
"""

	public final x as int
	public final y as int

	def constructor(X as int, Y as int):
		x = X
		y = Y		

	override def ToString():
		return string.Format("({0},{1})", x, y)

	override def GetHashCode():
		return (x + 23) ^ (( y + 37) << 16)

	override def Equals(other):
		return GetHashCode() == other.GetHashCode()


	
public class SortQueue[of T]:
"""
Items are sorted as added; Pop() returns first item
"""

	contents as List[of T]
	weights as List[of single]
	members as HashSet[of T]

	[Getter(Min)]
	min as single
	
	[Getter(Max)]
	max as single
	
	public Count as int:
		get:
			return weights.Count

	public def constructor():
		min = 0.0
		max = 0.0
		contents = List[of T]()
		weights = List[of single]()
		members = HashSet[of T]()

	def Add (item as T, score as single):
		if item in members:
			for idx as int, existing as T in enumerate(contents):
				if item == existing:
					contents.RemoveAt(idx)
					weights.RemoveAt(idx)
					break
		else:
			members.Add(item)

		insertion_point = bisect(0, weights.Count, score)
		contents.Insert(insertion_point, item)
		weights.Insert(insertion_point, score)
		min = Min(min, score)
		max = Max(max, score)


	def Pop() as T:
		result = contents[0]
		weights.RemoveAt(0)
		contents.RemoveAt(0)
		return result

	def Clear():
		min = 0.0
		max = 0.0
		members.Clear()
		weights.Clear()
		contents.Clear()

	private def bisect(first_index as int,  last_index as int, score as single) as int:
		delta = last_index - first_index
		if delta == 0:
			return first_index
		if delta == 1:
			return last_index

		midpoint = first_index + (delta / 2)
		test_w = weights[midpoint]

		if test_w == score:
			return midpoint

		if test_w < score:
			return bisect(midpoint, last_index, score)
		return bisect(first_index, midpoint, score)

[Serializable]
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

[Serializable]
public class WeightedLink:
"""
Destination, weight pair
"""
	public address as Address
	public weight as single

	def constructor(addr as Address, w as single):
		address = addr
		weight = w


public class Map(ScriptableObject, ISerializationCallbackReceiver):
"""
2-D array of cells connected by edges. 

Cells and Edges can both have costs (by default an edge cost )
"""

	[SerializeField]
	width as int

	[SerializeField]	
	height as int
	
	[SerializeField]
	_cells  as (Address)

	[SerializeField]
	_cell_values as (single)

	[SerializeField]
	_edges as (Edge)

	[SerializeField]
	_edge_values as (single)


	cells = Dictionary[of Address, single]()
	edges = Dictionary[of Edge, single]()

	public Size:
		get:
			return width * height

	public Width:
		get:
			return width
		set:
			width = value
			Rebuild()

	public Height:
		get:
			return height
		set: 
			height = value
			Rebuild()


	def OnEnabled():
		print "OnEnabled" 
		
		
	def OnBeforeSerialize():
		_edges = array(Edge, edges.Count)
		_edge_values = array(single, edges.Count)
		for idx as int, kv as KeyValuePair[of Edge, single] in enumerate(edges):
			_edges[idx] = kv.Key
			_edge_values[idx] = kv.Value
			
		_cells = array(Address, cells.Count)
		_cell_values = array(single, cells.Count)
		for idx as int, kv as KeyValuePair[of Address, single] in enumerate(cells):
			_cells[idx] = kv.Key
			_cell_values[idx] = kv.Value


	def OnAfterDeserialize():
		Debug.Log("AfterLoad")
		cells = Dictionary[of Address, single]()
		edges = Dictionary[of Edge, single]()
		for k as Address, v as single in zip(_cells, _cell_values):
			cells[k] = v

		for ke as Edge, ve as single in zip(_edges, _edge_values):
			edges[ke] = ve
	

	def Rebuild():
	"""
	create the map edge connections
	"""
		Debug.Log("Rebuild")
	
		addresses = (Address(x,y) for x in range(width) for y in range(height))
		
		sqrdist = { a as Address, b as Address | Abs(b.x - a.x) + Abs(b.y - a.y) } 
		costs = { 0: 0.0, 1:1.0, 2: 1.414}
		get_cost  = { a as Address, b as Address | costs[sqrdist(a, b)] }

		
		for addr in addresses:
			if not addr in cells:
				cells[addr]  = 1
			for conn in connections(addr):
				new_edge = Edge(addr, conn)
				if new_edge not in edges:
					edges[new_edge] = get_cost (addr, conn)

		counter = 0

		invalid_cell = {a as Address | a.x >= width or  a.y >= height}
		delenda = [each_cell for each_cell in cells.Keys if invalid_cell(each_cell)]
		for d in delenda:
			counter += 1
			cells.Remove(d)

		invalid_edge = {e as Edge | not (cells.ContainsKey(e.start) and cells.ContainsKey(e.end))}
		dead_edges = [each_edge for each_edge in edges.Keys if invalid_edge(each_edge)]
		for de in dead_edges:
			edges.Remove(de)

		Debug.Log(string.Format("Removed {0} cells", counter))

	def connections(addr as Address):
		valid_x = { t as Address | t.x > -1 and t.x < width}
		valid_y = { t as Address | t.y > -1 and t.y < height}
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
			yield WeightedLink(conn, edges[Edge(addr, conn)] + cells[conn])

	def cell_set(addr as Address, val as single):
		cells[addr] = val
		p as System.Predicate[of Address] =  { e as Address | e == addr } 
		addr_key = System.Array.FindIndex(_cells, p)
		_cell_values[addr_key] = val
		Debug.Log( string.Format("set {0} : {1}", addr_key, val))

	def cell_get(addr as Address):
		return cells[addr]

	def edge_set (edge as Edge, cost as single):
		edges[edge] = cost
		
		p as System.Predicate[of Edge] =  { e as Edge | e == edge } 
		
		edge_key = System.Array.FindIndex(_edges, p)
		_edge_values[edge_key] = cost
		

	def edge_get(edge as Edge):
		return edges[edge]


public class MapSearch:

	open_nodes as SortQueue[of Address]
	m_map as Map
	m_links as Dictionary[of Address, Address]

	public m_costs as Dictionary[of Address, single]
	public m_accuracy = 1
	visited as  List[of Address]



	def constructor(map_data as Map):
		m_map = map_data
		open_nodes = SortQueue[of Address]()
		m_links = Dictionary[of Address, Address]()
		m_costs = Dictionary[of Address, single]()
		visited = List[of Address]()


	def search(start as Address, end as Address):

		visited.Clear()
		m_costs.Clear()
		m_links.Clear()
		open_nodes.Clear()
		m_costs[start] = 0.0
		m_links[start] = start
		open_nodes.Add(start, 0)

		found = single.MaxValue
		found_count = 0

		while open_nodes.Count > 0 and found_count < m_accuracy:
			current_node = open_nodes.Pop() 
			cost_to_here = m_costs[current_node]

			for weightedLink in m_map.links(current_node):
				next_link = weightedLink.address
				next_cost = weightedLink.weight
				predicted_cost = cost_to_here + next_cost 

				if  next_link not in m_costs:
					m_costs[next_link] = single.MaxValue				
				node_cost = m_costs[next_link]
				
				if next_link == end:	
					found = Mathf.Min(found, predicted_cost)
					found_count += 1

				if predicted_cost <= node_cost and predicted_cost <=  found:
					guess_cost = heuristic(next_link, end)
					open_nodes.Add(next_link, guess_cost)
					m_links[next_link] = current_node
					m_costs[next_link] = predicted_cost
					
				
			visited.Add(current_node)

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
		return Vector2.Distance(
			Vector2(end.x, end.y),
			Vector2(current.x, current.y)) 
