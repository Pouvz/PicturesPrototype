using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class TeleportPlayer : MonoBehaviour
{
    [SerializeField] private Vector3 teleportLocation;
    
    private void OnTriggerEnter(Collider other)
    {
        other.gameObject.transform.position = teleportLocation;
    }
}
