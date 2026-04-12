Here is the **updated PRD section** with support for **dynamic model selection from Ollama**, written as a clean patch you can merge into your existing document.

---

# 🧩 PRD Update — Dynamic Model Selection (Ollama)

## 20. Model Selection System (NEW)

### 20.1 Objective

Allow users to **select any locally available model from Ollama** directly in the UI, instead of being limited to predefined models.

This enables:

* flexibility for power users
* compatibility with future models
* better hardware optimization (VRAM/CPU)

---

## 20.2 Functional Requirements

### UI Behavior

* A **model selector dropdown** must be available in the footer (as shown in UI)
* Displays:

  * current active model
  * list of installed Ollama models
* Allows switching models at runtime

### Example UI State

```text
Status: Ollama Active    [ llama3.2 ▼ ]
```

### Interaction Rules

* Clicking the dropdown opens a list of:

  * locally installed models
* Selecting a model:

  * updates active model immediately
  * triggers model warm-up in background
  * updates all subsequent translation requests

---

## 20.3 Backend Requirements

### Ollama Integration

The backend must query:

```bash
ollama list
```

Or via API:

```http
GET /api/tags
```

### Expected Response

```json
[
  {
    "name": "llama3.2",
    "size": "...",
    "modified_at": "..."
  },
  {
    "name": "gemma4:e2b"
  }
]
```

---

## 20.4 Model Registry (Updated)

### Previous Behavior

Static model mapping:

```yaml
text_translation:
  fast: gemma4:e2b
  balanced: gemma4:e4b
```

### New Behavior

Dynamic + optional presets:

```yaml
default_model: gemma4:e2b

presets:
  fast: gemma4:e2b
  balanced: gemma4:e4b
  quality: llama3.2

allow_user_override: true
```

---

## 20.5 Model Selection Flow

```text
UI Dropdown
   ↓
UI Bridge Service
   ↓
Backend API (/set-model)
   ↓
Model Lifecycle Service
   ↓
Ollama Gateway (warm model)
   ↓
Update active session state
```

---

## 20.6 Runtime Behavior

### On Model Change

* Cancel or finish current jobs safely
* Warm new model (non-blocking)
* Update global state:

```json
{
  "active_model": "llama3.2",
  "status": "warming"
}
```

* Once ready:

```json
{
  "active_model": "llama3.2",
  "status": "ready"
}
```

---

## 20.7 Performance Considerations

| Scenario             | Behavior                        |
| -------------------- | ------------------------------- |
| Large model selected | Show loading/warm-up indicator  |
| Model not loaded     | Lazy load                       |
| Low VRAM             | Allow fallback to smaller model |
| First run            | Preload default model           |

---

## 20.8 Error Handling

| Case                | Action                      |
| ------------------- | --------------------------- |
| Model not found     | Show error + fallback       |
| Ollama not running  | Show “Ollama Offline”       |
| Model fails to load | Retry + suggest alternative |

---

## 20.9 API Contract

### GET Available Models

```http
GET /models
```

Response:

```json
{
  "models": ["llama3.2", "gemma4:e2b", "gemma4:e4b"]
}
```

---

### SET Active Model

```http
POST /models/select
```

Request:

```json
{
  "model": "llama3.2"
}
```

Response:

```json
{
  "status": "warming"
}
```

---

### GET Current Model

```http
GET /models/current
```

Response:

```json
{
  "model": "llama3.2",
  "status": "ready"
}
```

---

## 20.10 UI State Requirements

### Footer States

| State   | Indicator                    |
| ------- | ---------------------------- |
| Active  | Green dot + model name       |
| Warming | Spinner + "Loading model..." |
| Error   | Red dot + error tooltip      |
| Offline | Gray + "Ollama not running"  |

---

## 20.11 Future Enhancements

* Model download UI (`ollama pull`)
* Model size + VRAM indicator
* Auto-recommend best model based on hardware
* Per-tab model selection:

  * text model
  * audio model
  * OCR model

---

## 20.12 Final Behavior Summary

* The system **no longer hardcodes models**
* It **adapts dynamically to Ollama**
* The user has **full control over model selection**
* Backend ensures:

  * safe switching
  * warm-up
  * fallback handling

---

## Final Decision Update

> The system must treat **Ollama as a dynamic model provider**, not a fixed dependency.

* Models are **discovered at runtime**
* Users can **switch models freely**
* System ensures **stability and performance**

---

If you want next step, I can generate:

* Backend Python implementation for `/models` endpoints
* QML component for this dropdown (Material You style)
* Full IPC schema between Quickshell ↔ backend
* Auto model recommendation logic based on your GPU (you mentioned 4060Ti/5070Ti earlier)
