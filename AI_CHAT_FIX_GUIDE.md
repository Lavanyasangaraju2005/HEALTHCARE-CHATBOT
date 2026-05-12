# AI Chat Connectivity Fix Guide

## Problem Analysis
The AI chat connectivity issue occurs when:
1. **Backend is not running** on port 8080
2. **Ollama service is not running** (configured AI model service)
3. **Database connection fails** (MySQL)
4. **Frontend cannot reach backend** (API endpoint misconfiguration)

---

## Quick Fix Checklist

### Step 1: Ensure MySQL is Running
```powershell
# Check if MySQL service is running
Get-Service MySQL80

# If not running, start it
Start-Service MySQL80
```

### Step 2: Start Ollama (Required for AI Chat)
Ollama is configured as the primary AI service. You need to:

1. **Download Ollama** from https://ollama.ai
2. **Start Ollama service**:
   ```powershell
   # On Windows, Ollama should run automatically as a service
   # Or start it manually:
   ollama serve
   ```
3. **Pull the model** (in another PowerShell window):
   ```powershell
   ollama pull gemma:2b
   ```
4. **Verify Ollama is running**:
   ```powershell
   # Test the endpoint
   curl http://localhost:11434/api/tags
   ```

### Step 3: Start the Backend (Java)
```powershell
# Navigate to backend directory
cd backend

# Build and run with Maven
mvn clean install
mvn spring-boot:run

# Or if already built:
java -jar target/healthcare-chat-assistant-1.0.0.jar
```

The backend should be running on `http://localhost:8080`

### Step 4: Start the Frontend (React/Vite)
```powershell
# Navigate to frontend directory
cd frontend

# Install dependencies (first time only)
npm install

# Start development server
npm run dev
```

The frontend will run on `http://localhost:5173`

---

## Configuration Files Created

### Frontend - `.env.local`
Located at: `frontend/.env.local`
```
VITE_API_BASE_URL=http://localhost:8080/api
```

This tells the frontend where to find the backend API.

### Backend - `.env`
Located at: `backend/.env`
Contains all configuration including:
- Database credentials
- Ollama service URL
- JWT settings
- File upload paths

---

## Troubleshooting

### Error: "Cannot POST /api/chat/message"
**Solution**: Backend is not running
- Check if Java process is running on port 8080
- Start the backend with `mvn spring-boot:run`

### Error: "Ollama connection failed"
**Solution**: Ollama service not running
- Start Ollama: `ollama serve`
- Verify with: `curl http://localhost:11434/api/tags`
- Pull the model: `ollama pull gemma:2b`

### Error: "Database connection error"
**Solution**: MySQL not available
- Ensure MySQL service is running: `Get-Service MySQL80`
- Check credentials in `backend/.env`
- Default: username=root, password=Shankar@2005@31

### Error: "Network error - Unable to connect to backend"
**Solution**: Frontend cannot reach backend
- Verify backend is running on http://localhost:8080
- Check if `VITE_API_BASE_URL` is set correctly in `frontend/.env.local`
- Clear browser cache and refresh (Ctrl+Shift+Delete)
- Check browser console for detailed errors

### Error: "CORS error"
**Solution**: Cross-origin request blocked
- Backend CORS is configured in `application.properties`
- Allowed origins: http://localhost:5173, http://localhost:3000
- If using different port, add to backend's `application.properties`

---

## Environment Variables Reference

### Frontend (.env.local)
- `VITE_API_BASE_URL` - Backend API base URL (default: http://localhost:8080/api)

### Backend (.env / application.properties)
- `OLLAMA_ENABLED` - Enable/disable Ollama (true/false)
- `OLLAMA_BASE_URL` - Ollama service URL (default: http://localhost:11434)
- `OLLAMA_MODEL` - Model to use (default: gemma:2b)
- `OPENAI_API_KEY` - Fallback OpenAI key (if Ollama disabled)
- Database credentials for MySQL connection

---

## Startup Command (All Services)

Run this script to start everything:

```powershell
# Terminal 1: Start MySQL
Get-Service MySQL80 | Start-Service

# Terminal 2: Start Ollama
ollama serve

# Terminal 3: Start Backend (from project root)
cd backend
mvn spring-boot:run

# Terminal 4: Start Frontend (from project root)
cd frontend
npm run dev
```

After all services are running:
- Frontend: http://localhost:5173
- Backend API: http://localhost:8080
- Ollama: http://localhost:11434

---

## Testing the Connection

1. Open frontend: http://localhost:5173
2. Register a new patient account
3. Go to Chat page
4. Send a test message: "Hello, I have a headache"
5. Check browser console (F12) for any errors
6. Check backend logs for DEBUG messages

---

## Still Having Issues?

1. **Check browser console** (F12 → Console tab) for JavaScript errors
2. **Check backend logs** for Java exceptions
3. **Verify all services** are running on correct ports:
   - `netstat -ano | findstr :8080` (backend)
   - `netstat -ano | findstr :5173` (frontend)
   - `netstat -ano | findstr :11434` (ollama)
4. **Check firewall** - ensure ports 8080, 5173, 11434 are not blocked
5. **Test Ollama directly**:
   ```powershell
   $body = @{
       model = "gemma:2b"
       messages = @(@{role = "user"; content = "hello"})
   } | ConvertTo-Json
   
   Invoke-WebRequest -Uri http://localhost:11434/v1/chat/completions `
     -Method Post -ContentType "application/json" -Body $body
   ```
