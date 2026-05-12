# Healthcare Chat Assistant - Setup & Troubleshooting Guide

## Quick Start (5 minutes)

### Prerequisites
- MySQL Server installed and running
- Java 11+ installed
- Node.js 16+ installed
- Ollama installed (for local AI)

### Step-by-Step Setup

#### 1. Make sure MySQL is running
```powershell
# Windows
Get-Service MySQL80 | Start-Service

# Or use Services app: Services.msc → MySQL80 → Start
```

#### 2. Start Ollama (Terminal 1)
```powershell
ollama serve
```
Wait for it to start, then in another terminal:
```powershell
ollama pull gemma:2b
```

#### 3. Start Backend (Terminal 2)
```powershell
cd .\backend
mvn spring-boot:run
```
Wait for: "Started HealthcareChatAssistantApplication"

#### 4. Start Frontend (Terminal 3)
```powershell
cd .\frontend
npm install  # First time only
npm run dev
```

#### 5. Open Application
Visit: http://localhost:5173
- Register a new patient account
- Go to Chat page
- Send a message

---

## Common Connection Issues & Fixes

### Issue: "Failed to send message" or "Connection Failed"

**Symptom**: Chat not sending messages or showing network error

**Root Cause**: Backend is not running on port 8080

**Fix**:
```powershell
# Check if backend is running
netstat -ano | findstr :8080

# If not running, start backend
cd backend
mvn spring-boot:run

# Wait for: "Started HealthcareChatAssistantApplication"
```

---

### Issue: "AI Service Unavailable" or Ollama Error

**Symptom**: Messages are stuck or showing "service unavailable"

**Root Cause**: Ollama is not running on port 11434

**Fix**:
```powershell
# Start Ollama
ollama serve

# In another terminal, check if model is available
curl http://localhost:11434/api/tags

# If no models, download gemma:2b
ollama pull gemma:2b

# Test Ollama directly
$body = @{
    model = "gemma:2b"
    messages = @(@{role = "user"; content = "hello"})
} | ConvertTo-Json

Invoke-WebRequest -Uri http://localhost:11434/v1/chat/completions `
  -Method Post -ContentType "application/json" -Body $body
```

---

### Issue: "Database connection error"

**Symptom**: Login/Registration fails, or messages don't save

**Root Cause**: MySQL not running or wrong credentials

**Fix**:
```powershell
# Check MySQL service
Get-Service MySQL80

# If stopped, start it
Start-Service MySQL80

# Check credentials in backend/.env
# Database: healthcare_db
# Username: root
# Password: Shankar@2005@31

# Verify MySQL is accessible
mysql -h localhost -u root -p

# Create database if needed
CREATE DATABASE healthcare_db;
```

---

### Issue: "CORS error" or "Blocked by CORS policy"

**Symptom**: Browser shows CORS error in console

**Root Cause**: Frontend and backend are on different origins

**Fix**:
1. Ensure backend CORS is configured
2. Edit `backend/src/main/resources/application.properties`:
   ```properties
   cors.allowed.origins=http://localhost:5173,http://localhost:3000
   ```
3. Restart backend

---

### Issue: Frontend can't connect to backend

**Symptom**: "ERR_NETWORK" or "Cannot reach backend"

**Root Cause**: Wrong API_BASE_URL or backend not accessible

**Fix**:
1. Check `frontend/.env.local`:
   ```
   VITE_API_BASE_URL=http://localhost:8080/api
   ```

2. Test backend directly:
   ```powershell
   curl http://localhost:8080
   
   # Should return 404 or redirect, not connection error
   ```

3. Check firewall - ensure port 8080 is not blocked

---

## Verification Checklist

Run the diagnostic script to check all services:
```powershell
.\CHECK_SERVICES.ps1
```

Or manually check each:

- [ ] MySQL running
  ```powershell
  Get-Service MySQL80 | Select-Object Status
  ```

- [ ] Backend running
  ```powershell
  netstat -ano | findstr :8080
  ```

- [ ] Ollama running
  ```powershell
  curl http://localhost:11434/api/tags
  ```

- [ ] Frontend accessible
  ```powershell
  Start-Process http://localhost:5173
  ```

---

## Port Reference

| Service | Port | URL | Config |
|---------|------|-----|--------|
| MySQL | 3306 | localhost:3306 | `backend/.env` |
| Ollama | 11434 | http://localhost:11434 | `backend/.env` |
| Backend API | 8080 | http://localhost:8080 | `application.properties` |
| Frontend Dev | 5173 | http://localhost:5173 | `vite.config.js` |

---

## Environment Files

### Frontend: `frontend/.env.local`
```ini
VITE_API_BASE_URL=http://localhost:8080/api
```

### Backend: `backend/.env` or `application.properties`
```properties
spring.datasource.url=jdbc:mysql://localhost:3306/healthcare_db
spring.datasource.username=root
spring.datasource.password=Shankar@2005@31
ollama.enabled=true
ollama.base.url=http://localhost:11434
ollama.model=gemma:2b
```

---

## Full Service Startup Order

1. **Start MySQL**
   ```powershell
   Start-Service MySQL80
   ```

2. **Start Ollama** (Terminal 1)
   ```powershell
   ollama serve
   ```

3. **Verify Ollama Models** (Terminal 2)
   ```powershell
   ollama pull gemma:2b
   curl http://localhost:11434/api/tags
   ```

4. **Start Backend** (Terminal 3)
   ```powershell
   cd backend
   mvn spring-boot:run
   ```
   Wait for: `Tomcat started on port(s): 8080`

5. **Start Frontend** (Terminal 4)
   ```powershell
   cd frontend
   npm run dev
   ```
   Wait for: `Local: http://localhost:5173`

6. **Open Application**
   ```powershell
   Start-Process http://localhost:5173
   ```

---

## Testing the Chat Feature

1. Register a new patient account
2. Navigate to Chat page
3. Send test message: "What should I do if I have a headache?"
4. Expected: AI response in English and Telugu

### If chat fails:
1. Open browser DevTools (F12)
2. Go to Console tab
3. Look for errors
4. Check Network tab for failed API calls
5. Run `CHECK_SERVICES.ps1` to verify all services

---

## Restarting Services

If something isn't working, restart in this order:

```powershell
# 1. Stop all services
Stop-Service MySQL80
# Kill Java process (Backend)
Get-Process java | Stop-Process -Force
# Kill Ollama
Get-Process ollama | Stop-Process -Force

# 2. Wait a few seconds
Start-Sleep -Seconds 3

# 3. Start again in order
Start-Service MySQL80
ollama serve  # Terminal 1

# Terminal 2
ollama pull gemma:2b

# Terminal 3
cd backend
mvn spring-boot:run

# Terminal 4
cd frontend
npm run dev
```

---

## Performance Notes

- First chat message may take 5-10 seconds (Ollama initialization)
- Subsequent messages are faster (1-3 seconds)
- If slow: check CPU/RAM usage
- If timeouts: increase `backend/src/main/resources/application.properties`:
  ```properties
  spring.mvc.async.request-timeout=60000
  ```

---

## Getting Help

If still having issues:

1. Check all services running: `.\CHECK_SERVICES.ps1`
2. Review backend logs (Terminal 3) for Java errors
3. Review frontend console (DevTools F12) for JS errors
4. Check Ollama logs for model issues
5. Verify all environment variables set correctly
6. Clear browser cache: Ctrl+Shift+Delete

---

## Next Steps

Once working:
- Test file upload feature
- Create appointments
- Try emergency alert feature
- Test multi-user scenario
