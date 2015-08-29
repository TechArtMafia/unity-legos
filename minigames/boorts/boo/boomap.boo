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
		result = m_list.Keys[count - 1]
		m_list.RemoveAt(count - 1 )
		return result

	def add( weight as single, addr as Address):
		if addr in m_list:
			m_list.Remove(addr)
		m_list.Add( addr, weight)





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
		Debug.Log(string.Format("{0} edges", m_edges.Count))


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
	m_costs as Dictionary[of Address, single]


	def constructor(map_data as Map):
		m_map = map_data
		m_OpenList = OpenList()
		m_links = Dictionary[of Address, Address]()
		m_costs = Dictionary[of Address, single]()


	def search(start as Address, end as Address):

		m_costs.Clear()
		m_links.Clear()
		m_costs[start] = -1.0
		m_links[start] = start
		m_OpenList.add(0.0, start) 

		found = false
		while m_OpenList.count > 0 and not found:
			current_node = m_OpenList.pop() 
			cost_to_here = m_costs[current_node]
			Debug.Log(current_node)

			for weightedLink in m_map.links(current_node):
				next_link = weightedLink.address
				next_cost = weightedLink.weight
				if next_link == end:
					m_links[next_link] = current_node
					found = true
					break

				if  next_link not in m_costs:
					m_costs[next_link] = single.MaxValue

				

				predicted_cost = cost_to_here + next_cost + \
									heuristic(current_node, next_link, end)
				node_cost = m_costs[next_link]
				if predicted_cost < node_cost and predicted_cost >= cost_to_here:
					m_OpenList.add(predicted_cost, next_link) # does this sort right?
					m_links[next_link] = current_node
					m_costs[next_link] = predicted_cost

		if not found:
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


	def heuristic(current as Address, next as Address, end as Address):
		return 0.0

public class boomap(MonoBehaviour):
	
	def Start():
		m = Map(12,12)
		test = MapSearch(m)
		start = Address(10,0)
		end = Address(4,7)
		blocker = Edge(Address(10,3), Address(10,2))
		m.edge_set(blocker,10)
		blocker = Edge(Address(10,2), Address(10,3))
		m.edge_set(blocker,10)

		for res in test.search(start, end):
			Debug.Log(string.Format("...{0}", res))