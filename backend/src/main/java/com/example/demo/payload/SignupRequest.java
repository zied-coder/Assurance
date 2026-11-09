package com.example.demo.payload;

public class SignupRequest {

    private String username;
    private String email;
    private String password;

    private String role;

    // 🆕 NOUVEAUX CHAMPS
    private String cin;
    private String phone;
    private String address;
    private String oldPassword;

    public SignupRequest() {}

    // getters & setters

    public String getUsername() { return username; }
    public void setUsername(String username) { this.username = username; }

    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }

    public String getPassword() { return password; }
    public void setPassword(String password) { this.password = password; }

    public String getOldPassword() { return oldPassword; }
    public void setOldPassword(String oldPassword) { this.oldPassword = oldPassword; }

    public String getRole() { return role; }
    public void setRole(String role) { this.role = role; }

    public String getCin() { return cin; }
    public void setCin(String cin) { this.cin = cin; }

    public String getPhone() { return phone; }
    public void setPhone(String phone) { this.phone = phone; }

    public String getAddress() { return address; }
    public void setAddress(String address) { this.address = address; }
}