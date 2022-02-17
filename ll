using System.Collections;
using UnityEngine;
using UnityEngine.SceneManagement;
using UnityEngine.UI;

public class car_script : MonoBehaviour
{
    WheelJoint2D[] wheelJoints;
    JointMotor2D frontWheel;
    JointMotor2D backWheel;
    public Text moneyUI;
    Animator animatorCH;

    public float maxBackSpeed = 1000f;
    public float angleRide = -50f;
    private float angleCar = 0f;
    float addedSectorTime = 10f;
    private int animationChoose;
    public int collectedMoney;

    public static bool dinoEating = false;

    public Button_script[] ControlCar;
    public GameObject ch;
    public GameObject jeep;

    //public GameObject[] sectors;
    //public GameObject newSectorStartPoint;

    public money money;
    public Car_Upgrade Car_Upgrade;
    public value_of_sectors valueOfSectors;
    public value_of_grounds valueOfGrounds;
    public Cars cars;

    public GameObject accelerationButton;
    public GameObject accelerationButtonPressed;
    public GameObject breakButton;
    public GameObject breakButtonPressed;
    public GameObject strelkaRPM;
    public GameObject strelkaSpeed;
    public GameObject buffPanel;
    public GameObject buffPanelActivePoint;
    private bool movebuffPanelLeft = false;
    private bool movebuffPanelRight = false;

    private Rigidbody2D rb;



    void Start()
    {
        jeep.GetComponent<SpriteRenderer>().sprite = cars.curretCar;
        valueOfGrounds.sectorsValue = 0f;
        valueOfSectors.sectorsValue = 1;
        rb = GetComponent<Rigidbody2D>();
        animatorCH = ch.GetComponent<Animator>();
        wheelJoints = gameObject.GetComponents<WheelJoint2D>();
        backWheel = wheelJoints[1].motor;
        frontWheel = wheelJoints[0].motor;
        Invoke("AddForce", 1f);
        collectedMoney = 0;
    }

    void FixedUpdate()
    {
        CarMoving();
        Panals_animations();
        if (movebuffPanelLeft == true)
        {
            buffPanel.transform.Translate(Vector3.left * 10 * Time.deltaTime);
        }
        if (movebuffPanelRight == true)
        {
            buffPanel.transform.Translate(Vector3.left * -10 * Time.deltaTime);
        }
    }

    void Panals_animations()
    {
        if (ControlCar[0].isClicked == true)
        {
            accelerationButton.SetActive(false);
            accelerationButtonPressed.SetActive(true);
        }
        else
        {
            accelerationButton.SetActive(true);
            accelerationButtonPressed.SetActive(false);

        }

        if (ControlCar[1].isClicked == true)
        {
            breakButton.SetActive(false);
            breakButtonPressed.SetActive(true);
        }
        else
        {
            breakButton.SetActive(true);
            breakButtonPressed.SetActive(false);
        }
    }

    private void AddForce()
    {
        jeep.GetComponent<Rigidbody2D>().AddForce(transform.right * 150000);
    }


    void CarMoving()
    {
        frontWheel.motorSpeed = backWheel.motorSpeed;
        angleCar = transform.localEulerAngles.z;

        strelkaSpeed.transform.localRotation = Quaternion.Euler(0, 0, -Mathf.Abs(rb.velocity.x * 10));

        strelkaRPM.transform.localRotation = Quaternion.Euler(0, 0, -Mathf.Abs((backWheel.motorSpeed + Car_Upgrade.MaximumSpeed) / 13));

        if (angleCar >= 180)
            angleCar = angleCar - 360;

        if (-backWheel.motorSpeed < -Car_Upgrade.MaximumSpeed && ControlCar[0].isClicked == true)
            backWheel.motorSpeed = backWheel.motorSpeed + Car_Upgrade.acctletation * Time.deltaTime;

        if (ControlCar[0].isClicked == true && backWheel.motorSpeed > 0)
            backWheel.motorSpeed = 0;

        if (ControlCar[1].isClicked == false && ControlCar[0].isClicked == false && backWheel.motorSpeed < 0)
            backWheel.motorSpeed = backWheel.motorSpeed - Car_Upgrade.deacceleration * Time.deltaTime;

        if (ControlCar[1].isClicked == true && backWheel.motorSpeed < 700)
            backWheel.motorSpeed = backWheel.motorSpeed - Car_Upgrade.breakWheel * Time.deltaTime;

        if (angleCar > 5 && angleCar < 85 && backWheel.motorSpeed < 500)
            backWheel.motorSpeed = backWheel.motorSpeed - angleRide * Mathf.PI * (angleCar / 180);

        if (angleCar < -5 && angleCar > -85)
            backWheel.motorSpeed = backWheel.motorSpeed - angleRide * Mathf.PI * (angleCar / 180);



        wheelJoints[1].motor = backWheel;
        wheelJoints[0].motor = frontWheel;
    }

    //private void AngleCarMoving()
    //{
    //    if ((ControlCar[0].isClicked == false && backWheel.motorSpeed < 0) || (ControlCar[0].isClicked == false && backWheel.motorSpeed == 0 && angleCar < 0))
    //        backWheel.motorSpeed = Mathf.Clamp(backWheel.motorSpeed - angleRide * Time.deltaTime, Car_Upgrade.MaximumSpeed, 0);

    //    else if ((ControlCar[0].isClicked == false && backWheel.motorSpeed > 0) || (ControlCar[0].isClicked == false && backWheel.motorSpeed == 0 && angleCar > 0))
    //        backWheel.motorSpeed = Mathf.Clamp(backWheel.motorSpeed - -angleRide * Time.deltaTime, 0, maxBackSpeed);
    //}

    //private void OnCollisionStay2D(Collider2D collision)
    //{
    //    if (collision.gameObject.tag == "ground")
    //        AngleCarMoving();
    //}

    public void Restart()
    {
        money.moneyStatus -= collectedMoney;
        SceneManager.LoadScene(SceneManager.GetActiveScene().buildIndex);
        //dinoEating = false;
    }

    public void GoToMenu()
    {
        money.moneyStatus -= collectedMoney;
        SceneManager.LoadScene(0); ;
    }

    IEnumerator SectorTimer()
    {
        yield return new WaitForSeconds(20f);
        yield return new WaitForSeconds(addedSectorTime);
        dinoEating = true;
        animatorCH.Play("dino_eating");
        Invoke("Restart", 2.35f);
    }


    private void ActivateButtons()
    {
        ControlCar[0].gameObject.SetActive(true);
        ControlCar[1].gameObject.SetActive(true);
        backWheel.motorSpeed = -200;
    }

    private void OnTriggerEnter2D(Collider2D collision)
    {
        if (collision.gameObject.tag == "sector" && dinoEating == false)
        {
            StopCoroutine("SectorTimer");
            addedSectorTime = 0;
            StartCoroutine("SectorTimer");
            animationChoose = UnityEngine.Random.Range(1, 3);
            animatorCH.Play("next_sector" + animationChoose);
            valueOfSectors.sectorsValue -= 1;
        }

        if (collision.gameObject.tag == "sell_spot")
        {
            ControlCar[0].gameObject.SetActive(false);
            ControlCar[1].gameObject.SetActive(false);
            ControlCar[0].isClicked = false;
            ControlCar[1].isClicked = false;
            Invoke("ActivateButtons", 3.0f);
            backWheel.motorSpeed = 0;
            animatorCH.Play("egg_delivered");
            collectedMoney += 5;
        }

        if(collision.gameObject.tag == "buff")
        {
            movebuffPanelLeft = true;
            Invoke("moveBuffPanelLeftFalse", 0.5f);
            
        }

        if (collision.gameObject.tag == "Finish")
        {
            PlayerPrefs.SetInt("moneyToSave", money.moneyStatus);
            SceneManager.LoadScene(0);
        }
    }

    public void CRAZY_FIRE()
    {
        addedSectorTime += 100000;
        movebuffPanelRight = true;
        Invoke("moveBuffPanelRightFalse", 0.5f);
    }

    void moveBuffPanelLeftFalse()
    {
        movebuffPanelLeft = false;
    }

    void moveBuffPanelRightFalse()
    {
        movebuffPanelRight = false;
    }


}

