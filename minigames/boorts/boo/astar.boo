import System.Collections.Generic


public class OpenNodes:

	m_list = SortedList[of int, single]()

	count as int:
		get:
			return m_list.Count

	def pop():
		result = m_list.Keys[count - 1]
		m_list.Remove(result)
		return result

	def add( weight as single, node as int):
		if node in m_list:
			m_list.Remove(node)
		m_list.Add( node, weight)


public class Graph[of T]:

	m_edges as Dictionary[of int, (int)]
	m_values as Dictionary[of int, T]

	def constructor():
		
		m_edges = Dictionary[of int, (int)]()
		m_values = Dictionary[of int, T]()

	def links(node as int):
		return  m_edges[node]
	
	def member(node as int):
		return m_values[node]

	def add(index as int, member as T, *links as (int)):
		m_edges[index] = links
		m_values[index] = member



public class Search[of T]:

	m_OpenNodes as OpenNodes
	m_links as Dictionary[of int, int]
	m_costs as Dictionary[of int, single]
	m_graph as Graph[of T]


	def constructor(graph as Graph[of T]):
		m_graph = graph
		m_OpenNodes = OpenNodes()
		m_links = Dictionary[of int, int]()
		m_costs = Dictionary[of int, single]()


	def search(start as int, end as int):

		m_costs.Clear()

		m_costs[start] = -0
		m_links[start] = -1
		m_OpenNodes.add(int.MinValue, start) 

		found = false
		while m_OpenNodes.count > 0 and not found:
			current_node = m_OpenNodes.pop() 
			cost_to_here = m_costs[current_node]

			for next_link in m_graph.links(current_node):
				if next_link == end:
					m_links[next_link] = current_node
					found = true

					break

				if  next_link not in m_costs:
					m_costs[next_link] = int.MaxValue

				predicted_cost = cost_to_here + heuristic(current_node, next_link, end)
				node_cost = m_costs[next_link]
				if predicted_cost < node_cost and predicted_cost > cost_to_here:
					m_OpenNodes.add(predicted_cost, next_link) # does this sort right?
					m_links[next_link] = current_node
					m_costs[next_link] = predicted_cost

		if not found:
			return List[of int]()

		return recurse_path(start, end)

	def recurse_path(st as int, node as int):	
		result = List[of int]()
		prev = node
		while prev > -1:
			result.Add(prev)
			prev = m_links[prev] 
		return result


	def heuristic(current as int, next_node as int, end as int) as single:
		
		if (current < next_node):
			return 2.0
		return 0.5


	
public class astar(MonoBehaviour):

	pass




