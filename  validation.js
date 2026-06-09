function validate() {
    let u = document.forms[0].username.value;
    if (u === "") {
        alert("Enter username");
        return false;
    }
}