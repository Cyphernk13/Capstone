# Project 10: Internal DNS Setup



## Goal

Configure DNS to resolve hostnames to IP addresses.



## Implementation

1. **DNS Server:** Used the existing Windows Domain Controller (Project 9).

2. **Configuration:** Created an 'A Record' for `webapp.project9.local`.

   - Target: Linux VM IP (`172.31.77.1`).

3. **Verification:**

   - Executed `nslookup webapp.project9.local`.

   - Confirmed it resolved to the correct Linux IP.



## Proof

(See attached screenshot of nslookup command in the submitted file).
