import UnityEngine
import UnityEditor
import System.Collections.Generic

public class armyMember (MonoBehaviour):

	public m_army as army

	public static def owner(gmo as GameObject):
		mamber_comp = gmo.GetComponent(armyMember)
		if not mamber_comp :
			return null 
		return mamber_comp.m_army

