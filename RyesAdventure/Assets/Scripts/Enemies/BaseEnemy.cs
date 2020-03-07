using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class BaseEnemy : MonoBehaviour
{
    [Header("Base Stats")]
    public ushort healthPoints;
    protected int currentHealth;
    public ushort damage;

    void Awake()
    {
        currentHealth = healthPoints;
    }

    protected void FaceCamera()
    {
        transform.rotation = Camera.main.transform.rotation;
    }

    protected void LoseLife(ushort damage)
    {
        currentHealth -= damage;
    }
}
