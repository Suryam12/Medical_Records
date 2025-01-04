// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

 struct Patient {
        address patientAddress;
        uint patientID;
        string name;
        uint8 age;
        string[] diseases;
    }

    struct Doctor {
        address doctorAddress;
        uint doctorID;
        string name;
        string qualification;
        string workPlace;
    }

    struct Medicine {
        uint medicineID;
        string name;
        string expiryDate;
        string dose;
        uint8 price;
    }

contract medicalRecords {

    Patient public viewRecord; //7. View patient data. This function helps to view patient data stored in Blockchain
    
    address public admin;
    uint public doctorCount;
    uint public patientCount;
    uint public medicineCount;

    constructor(){
        admin = msg.sender;
    }

    modifier OnlyAdmin() {
        require(msg.sender == admin,"Only Admin Is Authorized");
        _;
    }

    modifier OnlyDoctor(uint _doctorID, address _doctorAddress) {
        require(_doctorID == doctors[_doctorID].doctorID,"Only Doctor Is Authorized");
        require(msg.sender == doctor[_doctorAddress].doctorAddress,"Only Doctor Is Authorized");
        //require(msg.sender == doctor[_doctorAddress].doctorAddress,"Only Doctor Is Authorized");
        _;
    }

    modifier OnlyPatient(uint _patientID, address _patientAddress) {
        require(_patientID == patients[_patientID].patientID,"Only Patient Is Authorized");
        require(msg.sender == patient[_patientAddress].patientAddress,"Only Patient Is Authorized");
        //require(msg.sender == patient[_patientAddress].patientAddress,"Only Patient Is Authorized");
        _;
    }

    // Mappings for storing records
    mapping(uint => Patient)  patients;
    mapping(address => Patient)  patient;
    mapping(uint => Doctor)  doctors;
    mapping(address => Doctor)  doctor;
    mapping(uint => Medicine)  medicines;
    mapping(uint => uint[])  prescribedMedicines;  //patientID => diseases

    // Event emitted when a patient or doctor is registered
    event PatientRegistered(address patientAddress, string name, uint patientID);
    event DoctorRegistered(address doctorAddress, string name, uint doctorID);
    event MedicineRegistered(uint medicineID, string name, string expiryDate);

//1.This function is used to register a new doctor to the ledger.
    function registerDoctor
        (address _doctorAddress,
        uint doctorID,
        string memory _name,
        string memory _qualification,
        string memory _workPlace) public OnlyAdmin{
            doctorCount++;
            doctors[doctorID] = Doctor(_doctorAddress,doctorID, _name, _qualification, _workPlace);
            emit DoctorRegistered(_doctorAddress, _name,doctorID);
    }
//2.This function is used to register a new patient to the ledger. 
    function registerPatient
        (uint _doctorID, address _doctorAddress, address _patientAddress,
        uint patientID,
        string memory _name,
        uint8 _age,
        string[] memory _disease) public OnlyDoctor(_doctorID, _doctorAddress) {    
            patientCount++;
            patients[patientID] = Patient(_patientAddress,patientID, _name, _age, _disease);
            emit PatientRegistered(_patientAddress, _name,patientID);
    }

//3.This function is used to add a patient's disease. 
    function addNewDisease(uint _doctorID, address _doctorAddress, uint _patientID,string memory _disease) 
    public OnlyDoctor(_doctorID,_doctorAddress){
            patients[_patientID].diseases.push(_disease); // string[] array struct
    }
//4.This function is used to add medicines. 
    function addMedicine
        (uint _doctorID,address _doctorAddress, uint medicineID,
        string memory _name,
        string memory _expiryDate,
        string memory _dose,
        uint8 _price) public OnlyAdmin OnlyDoctor(_doctorID, _doctorAddress) {
            medicineCount++;
            medicines[medicineID] = Medicine(medicineID, _name, _expiryDate, _dose , _price);
            emit MedicineRegistered(medicineID, _name, _expiryDate);
    }
    
//5.This function is used by doctors to prescribe medicine to a patient. 
    function prescribeMedicine(uint _doctorID, address _doctorAddress, uint _patientID, uint _medicineID) public 
    OnlyDoctor(_doctorID, _doctorAddress) {
         prescribedMedicines[_patientID].push(_medicineID);
     }
//6.This function helps patients to update their age. Update patient details by patient
    function updateAge(uint _patientID, address _patientAddress, uint8 _newAge) public OnlyPatient(_patientID, _patientAddress) {
        patients[_patientID].age = _newAge ;
    }

//7. This function helps to view ONLY DISEASE wrt ID of patient stored in Blockchain.
    function PatientIDandDiseade(uint _patientID) public view returns (uint patientID, string[] memory diseases) {
        Patient memory patientInfo = patients[_patientID];
        return (patientInfo.patientID, patientInfo.diseases);
    }
//important lesson : use patientInfo.patientID notpatients.patientID 
//         Patient memory patientInfo = patients[_patientID];
//         return (patients.patientID,patients.diseases);
//     }

//8.This function helps to fetch medicine details. 
    function viewMedicine(uint medicineID) public view returns (Medicine memory) {
        return(medicines[medicineID]) ;
    }

//9.This function helps a doctor to view patient data.
    function viewPatientByDoctor(uint _doctorID, address _doctorAddress, uint patientID) public view OnlyDoctor(_doctorID, _doctorAddress) returns (Patient memory) {
        return(patients[patientID]) ;
    }

//10.This function helps the doctor to view prescribed medicine to the patient . 
    function viewPrescribedMedicines(uint _doctorID, address _doctorAddress, uint _patientID) 
    public view OnlyDoctor(_doctorID, _doctorAddress) 
        returns (uint[] memory) {
        return prescribedMedicines[_patientID];  
    }  

//11.This function helps to view doctor details. 
    function viewDoctorByID(uint doctorID) public view returns (Doctor memory) {
        return(doctors[doctorID]) ;
    }
}
