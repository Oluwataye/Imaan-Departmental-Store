# Imaan Departmental Store

A modern, full-featured departmental store management system built with React, TypeScript, and Supabase.

## 🏪 Overview

Imaan Departmental Store is a comprehensive retail management solution designed to streamline operations for departmental stores. The system provides role-based access control, inventory management, point-of-sale (POS) functionality, sales tracking, and detailed reporting.

## ✨ Features

### Role-Based Access Control
- **Admin**: Full system access, user management, and system settings
- **Store Manager**: Inventory management, product operations, and reporting
- **Cashier**: Point-of-sale operations and sales transactions

### Inventory Management
- Product CRUD operations with SKU tracking
- Batch number and expiry date management
- Low stock alerts and reorder level tracking
- Category-based organization
- Real-time stock level monitoring

### Point of Sale (POS)
- Fast product search and selection
- Retail and wholesale sale types
- Discount management (percentage and manual)
- Receipt printing with customizable templates
- Customer information capture

### Sales & Transactions
- Complete sales history tracking
- Transaction management
- Sales analytics and reporting
- Print history with analytics

### Reporting
- Expiring products report
- Sales reports by date range
- Inventory reports
- Low stock alerts
- User activity tracking

### Offline Support
- Offline-first architecture
- Automatic data synchronization
- Local storage fallback
- Queue-based sync mechanism

## 🛠️ Technology Stack

- **Frontend**: React 18, TypeScript, Vite
- **UI Framework**: Tailwind CSS, Radix UI
- **State Management**: TanStack Query (React Query)
- **Backend**: Supabase (PostgreSQL, Edge Functions)
- **Authentication**: Supabase Auth
- **Routing**: React Router v6
- **Forms**: React Hook Form + Zod validation
- **Icons**: Lucide React
- **Charts**: Recharts

## 📋 Prerequisites

- Node.js 18+ and npm
- Supabase account
- Git

## 🚀 Getting Started

### 1. Clone the Repository

```bash
git clone https://github.com/Oluwataye/Imaan-Departmental-Store.git
cd Imaan-Departmental-Store
```

### 2. Install Dependencies

```bash
npm install
```

### 3. Environment Setup

Create a `.env.local` file in the root directory:

```env
VITE_SUPABASE_URL=your_supabase_project_url
VITE_SUPABASE_ANON_KEY=your_supabase_anon_key
```

### 4. Database Setup

1. Create a new Supabase project
2. Run the database migrations (SQL scripts will be provided)
3. Set up the required tables:
   - `users`
   - `inventory`
   - `sales`
   - `stock_movements`
   - `print_analytics`
   - `store_settings`

### 5. Run Development Server

```bash
npm run dev
```

The application will be available at `http://localhost:5173`

## 📦 Build for Production

```bash
npm run build
```

The production-ready files will be in the `dist` directory.

## 🔐 Default Credentials

After setting up the database, create an admin user through Supabase Auth and assign the `ADMIN` role.

## 📱 Features in Detail

### Inventory Management
- Add, edit, and delete products
- Track multiple batches per product
- Monitor expiry dates
- Set reorder levels
- Manage suppliers
- Generate inventory reports

### Sales Operations
- Quick product search
- Barcode scanning support (planned)
- Multiple payment methods
- Customer information capture
- Wholesale and retail pricing
- Discount application
- Receipt generation and printing

### User Management
- Create and manage users
- Assign roles and permissions
- Track user activity
- Audit logs

### Settings
- Store information management
- Receipt customization
- Print settings
- Theme preferences
- System configuration

## 🗂️ Project Structure

```
src/
├── components/          # React components
│   ├── admin/          # Admin-specific components
│   ├── cashier/        # Cashier/POS components
│   ├── manager/        # Manager components
│   ├── layout/         # Layout components
│   ├── receipts/       # Receipt components
│   ├── reports/        # Report components
│   └── ui/             # Reusable UI components
├── contexts/           # React contexts
├── hooks/              # Custom React hooks
├── integrations/       # External integrations
├── lib/                # Utility libraries
├── pages/              # Page components
├── types/              # TypeScript type definitions
└── utils/              # Utility functions
```

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## 📄 License

This project is licensed under the MIT License.

## 👨‍💻 Author

**Oluwataye**
- GitHub: [@Oluwataye](https://github.com/Oluwataye)

## 🙏 Acknowledgments

- Built with [Vite](https://vitejs.dev/)
- UI components from [Radix UI](https://www.radix-ui.com/)
- Backend powered by [Supabase](https://supabase.com/)
- Icons by [Lucide](https://lucide.dev/)

## 📞 Support

For support, please open an issue in the GitHub repository.

---

**Note**: This project was refactored from a pharmacy management system to a generic departmental store system, maintaining all core functionality while adapting to retail operations.
