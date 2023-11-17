using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ToggleObjects : MonoBehaviour
{
    [SerializeField] private GameObject[] objectsToEnable;
    [SerializeField] private GameObject[] objectsToDisable;
    
    private void OnTriggerEnter(Collider other)
    {
        foreach (var obj in objectsToEnable)
        {
            obj.SetActive(true);
        }
        foreach (var obj in objectsToDisable)
        {
            obj.SetActive(false);
        }
    }
}
 