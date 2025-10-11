from fastapi import APIRouter
from app.controllers import auth_controller, users_controller, herd_controller, nutrition_controller, health_controller, reproduction_controller, pastures_controller, finance_controller, reports_controller

router = APIRouter()

# Authentication routes
router.post("/register", auth_controller.register)
router.post("/login", auth_controller.login)

# User management routes
router.get("/users", users_controller.get_users)
router.post("/users", users_controller.create_user)
router.put("/users/{user_id}", users_controller.update_user)
router.delete("/users/{user_id}", users_controller.delete_user)

# Herd management routes
router.get("/herd", herd_controller.get_herd)
router.post("/herd", herd_controller.add_animal)
router.put("/herd/{animal_id}", herd_controller.update_animal)
router.delete("/herd/{animal_id}", herd_controller.delete_animal)

# Nutrition management routes
router.post("/nutrition", nutrition_controller.plan_nutrition)

# Health management routes
router.post("/health", health_controller.record_health_check)

# Reproduction management routes
router.post("/reproduction", reproduction_controller.record_reproduction_event)

# Pastures management routes
router.post("/pastures", pastures_controller.manage_pastures)

# Finance management routes
router.post("/finance", finance_controller.record_financial_transaction)

# Reports routes
router.get("/reports", reports_controller.generate_reports)

# Include additional routes as needed

