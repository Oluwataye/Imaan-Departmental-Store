import { useAuth } from "@/contexts/AuthContext";
import CashierDashboard from "./CashierDashboard";
import ManagerDashboard from "./ManagerDashboard";
import AdminDashboardContent from "@/components/admin/AdminDashboardContent";
import { useInventoryAlerts } from "@/hooks/useInventoryAlerts";

const Dashboard = () => {
  const { user } = useAuth();

  // Trigger inventory alert notifications
  useInventoryAlerts();

  if (!user) {
    return <div>Loading...</div>;
  }

  switch (user.role) {
    case "CASHIER":
      return <CashierDashboard />;
    case "STORE_MANAGER":
      return <ManagerDashboard />;
    case "ADMIN":
    default:
      return <AdminDashboardContent />;
  }
};

export default Dashboard;

