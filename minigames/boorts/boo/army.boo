import UnityEngine
import UnityEditor
import System.Collections.Generic

public class army (MonoBehaviour):

	public m_capacity = 12
	public m_prototype as GameObject
	public m_members as List[of GameObject]


	def Start():
		for item in range(m_capacity):
			entry = Instantiate(m_prototype) as GameObject
			entry.SetActive( false)
			member = entry.GetComponent(armyMember)
			member.m_army = self
			m_members.Add(entry)