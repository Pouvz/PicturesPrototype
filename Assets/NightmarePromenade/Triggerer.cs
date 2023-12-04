using System;
using UnityEngine;
using UnityEngine.Events;

public class Triggerer : MonoBehaviour
{
    [SerializeField] private UnityEvent<Collider> onTriggerEnter;
    [SerializeField] private UnityEvent<Collider> onTriggerStay;
    [SerializeField] private UnityEvent<Collider> onTriggerExit;
    
    private void OnTriggerEnter(Collider other)
    {
        onTriggerEnter.Invoke(other);
    }
    
    private void OnTriggerStay(Collider other)
    {
        onTriggerStay.Invoke(other);
    }
    
    private void OnTriggerExit(Collider other)
    {
        onTriggerExit.Invoke(other);
    }
    
    private MeshRenderer _meshRenderer;
    private void Awake()
    {
        _meshRenderer = GetComponent<MeshRenderer>();
        
        #if !UNITY_EDITOR
        _meshRenderer.enabled = false;
        #endif
    }
}
