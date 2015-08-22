import UnityEngine
import System.Collections.Generic


public class UnitAction(ScriptableObject	):
	public m_target  as Vector3


public class unit (MonoBehaviour):

	public m_speed = 5.0
	m_goals as Queue[of UnitAction]
	m_current as UnitAction
	m_xform as Transform
	m_delta as Vector3
	m_army as army


	def Start():
		m_goals = Queue[of UnitAction]()
		m_xform = gameObject.transform
		m_army = armyMember.owner(gameObject)


	def  Update():
		if m_goals.Count == 0:
			for n in range(3):
				v3 = Random.insideUnitCircle * 10
				UA as UnitAction = ScriptableObject.CreateInstance(UnitAction) 
				UA.m_target = Vector3(v3.x, 0, v3.y)
				m_goals.Enqueue( UA)	

		m_current = m_goals.Peek() 
		
		m_delta = m_current.m_target - m_xform.position
		pos = m_xform.position
		if (m_delta.magnitude < .1):
			m_goals.Dequeue()
			return

		normalized = m_delta.normalized
		move  = normalized * Time.deltaTime * m_speed
		m_xform.LookAt(m_current.m_target)
		m_xform.position  += move	



