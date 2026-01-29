-- =====================================================
-- IMAAN DEPARTMENTAL STORE - DATABASE SCHEMA
-- =====================================================
-- This script creates all necessary tables for the store management system
-- Run this in Supabase SQL Editor

-- =====================================================
-- 1. USERS TABLE (extends Supabase auth.users)
-- =====================================================
CREATE TABLE IF NOT EXISTS public.users (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  email TEXT UNIQUE NOT NULL,
  username TEXT UNIQUE,
  name TEXT,
  role TEXT NOT NULL CHECK (role IN ('ADMIN', 'STORE_MANAGER', 'CASHIER')),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Enable RLS
ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;

-- Users can read their own data
CREATE POLICY "Users can read own data" ON public.users
  FOR SELECT USING (auth.uid() = id);

-- Admins can read all users
CREATE POLICY "Admins can read all users" ON public.users
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM public.users
      WHERE id = auth.uid() AND role = 'ADMIN'
    )
  );

-- Admins can insert users
CREATE POLICY "Admins can insert users" ON public.users
  FOR INSERT WITH CHECK (
    EXISTS (
      SELECT 1 FROM public.users
      WHERE id = auth.uid() AND role = 'ADMIN'
    )
  );

-- Admins can update users
CREATE POLICY "Admins can update users" ON public.users
  FOR UPDATE USING (
    EXISTS (
      SELECT 1 FROM public.users
      WHERE id = auth.uid() AND role = 'ADMIN'
    )
  );

-- =====================================================
-- 2. SUPPLIERS TABLE
-- =====================================================
CREATE TABLE IF NOT EXISTS public.suppliers (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  contact_person TEXT,
  email TEXT,
  phone TEXT,
  address TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE public.suppliers ENABLE ROW LEVEL SECURITY;

CREATE POLICY "All authenticated users can read suppliers" ON public.suppliers
  FOR SELECT USING (auth.role() = 'authenticated');

CREATE POLICY "Admins and managers can manage suppliers" ON public.suppliers
  FOR ALL USING (
    EXISTS (
      SELECT 1 FROM public.users
      WHERE id = auth.uid() AND role IN ('ADMIN', 'STORE_MANAGER')
    )
  );

-- =====================================================
-- 3. INVENTORY TABLE
-- =====================================================
CREATE TABLE IF NOT EXISTS public.inventory (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  sku TEXT UNIQUE NOT NULL,
  category TEXT NOT NULL,
  quantity INTEGER NOT NULL DEFAULT 0 CHECK (quantity >= 0),
  unit TEXT NOT NULL DEFAULT 'units',
  price DECIMAL(10, 2) NOT NULL CHECK (price >= 0),
  cost_price DECIMAL(10, 2) CHECK (cost_price >= 0),
  reorder_level INTEGER NOT NULL DEFAULT 10,
  expiry_date DATE,
  manufacturer TEXT,
  batch_number TEXT,
  supplier_id UUID REFERENCES public.suppliers(id),
  restock_invoice_number TEXT,
  last_updated_by UUID REFERENCES public.users(id),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE public.inventory ENABLE ROW LEVEL SECURITY;

CREATE POLICY "All authenticated users can read inventory" ON public.inventory
  FOR SELECT USING (auth.role() = 'authenticated');

CREATE POLICY "Admins and managers can manage inventory" ON public.inventory
  FOR ALL USING (
    EXISTS (
      SELECT 1 FROM public.users
      WHERE id = auth.uid() AND role IN ('ADMIN', 'STORE_MANAGER')
    )
  );

-- =====================================================
-- 4. PRODUCT BATCHES TABLE
-- =====================================================
CREATE TABLE IF NOT EXISTS public.product_batches (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  product_id UUID NOT NULL REFERENCES public.inventory(id) ON DELETE CASCADE,
  batch_number TEXT NOT NULL,
  expiry_date DATE NOT NULL,
  quantity INTEGER NOT NULL CHECK (quantity >= 0),
  cost_price DECIMAL(10, 2),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(product_id, batch_number)
);

ALTER TABLE public.product_batches ENABLE ROW LEVEL SECURITY;

CREATE POLICY "All authenticated users can read batches" ON public.product_batches
  FOR SELECT USING (auth.role() = 'authenticated');

CREATE POLICY "Admins and managers can manage batches" ON public.product_batches
  FOR ALL USING (
    EXISTS (
      SELECT 1 FROM public.users
      WHERE id = auth.uid() AND role IN ('ADMIN', 'STORE_MANAGER')
    )
  );

-- =====================================================
-- 5. SALES TABLE
-- =====================================================
CREATE TABLE IF NOT EXISTS public.sales (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  transaction_id TEXT UNIQUE NOT NULL,
  cashier_id UUID REFERENCES public.users(id),
  cashier_name TEXT,
  cashier_email TEXT,
  customer_name TEXT,
  customer_phone TEXT,
  business_name TEXT,
  business_address TEXT,
  sale_type TEXT NOT NULL CHECK (sale_type IN ('retail', 'wholesale')),
  subtotal DECIMAL(10, 2) NOT NULL,
  discount_percentage DECIMAL(5, 2) DEFAULT 0,
  manual_discount DECIMAL(10, 2) DEFAULT 0,
  total DECIMAL(10, 2) NOT NULL,
  items JSONB NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE public.sales ENABLE ROW LEVEL SECURITY;

CREATE POLICY "All authenticated users can read sales" ON public.sales
  FOR SELECT USING (auth.role() = 'authenticated');

CREATE POLICY "Cashiers can insert sales" ON public.sales
  FOR INSERT WITH CHECK (auth.role() = 'authenticated');

-- =====================================================
-- 6. STOCK MOVEMENTS TABLE
-- =====================================================
CREATE TABLE IF NOT EXISTS public.stock_movements (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  product_id UUID NOT NULL REFERENCES public.inventory(id) ON DELETE CASCADE,
  quantity_change INTEGER NOT NULL,
  previous_quantity INTEGER NOT NULL,
  new_quantity INTEGER NOT NULL,
  type TEXT NOT NULL CHECK (type IN ('SALE', 'ADJUSTMENT', 'ADDITION', 'RETURN', 'INITIAL')),
  reason TEXT,
  reference_id TEXT,
  created_by UUID REFERENCES public.users(id),
  cost_price_at_time DECIMAL(10, 2),
  unit_price_at_time DECIMAL(10, 2),
  created_at TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE public.stock_movements ENABLE ROW LEVEL SECURITY;

CREATE POLICY "All authenticated users can read stock movements" ON public.stock_movements
  FOR SELECT USING (auth.role() = 'authenticated');

CREATE POLICY "System can insert stock movements" ON public.stock_movements
  FOR INSERT WITH CHECK (auth.role() = 'authenticated');

-- =====================================================
-- 7. PRINT ANALYTICS TABLE
-- =====================================================
CREATE TABLE IF NOT EXISTS public.print_analytics (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  sale_id UUID REFERENCES public.sales(id),
  receipt_id TEXT,
  cashier_id UUID REFERENCES public.users(id),
  cashier_name TEXT,
  customer_name TEXT,
  print_status TEXT NOT NULL CHECK (print_status IN ('success', 'failed', 'cancelled')),
  error_type TEXT,
  error_message TEXT,
  print_duration_ms INTEGER,
  is_reprint BOOLEAN DEFAULT FALSE,
  sale_type TEXT,
  total_amount DECIMAL(10, 2),
  created_at TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE public.print_analytics ENABLE ROW LEVEL SECURITY;

CREATE POLICY "All authenticated users can read print analytics" ON public.print_analytics
  FOR SELECT USING (auth.role() = 'authenticated');

CREATE POLICY "System can insert print analytics" ON public.print_analytics
  FOR INSERT WITH CHECK (auth.role() = 'authenticated');

-- =====================================================
-- 8. STORE SETTINGS TABLE
-- =====================================================
CREATE TABLE IF NOT EXISTS public.store_settings (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL DEFAULT 'Imaan Departmental Store',
  address TEXT,
  phone TEXT,
  email TEXT,
  logo_url TEXT,
  print_show_logo BOOLEAN DEFAULT TRUE,
  print_show_address BOOLEAN DEFAULT TRUE,
  print_show_email BOOLEAN DEFAULT TRUE,
  print_show_phone BOOLEAN DEFAULT TRUE,
  print_show_footer BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Insert default settings
INSERT INTO public.store_settings (name, address, phone, email)
VALUES (
  'Imaan Departmental Store',
  '123 Main Street, Ikeja, Lagos',
  '+234 123 456 7890',
  'info@imaanstore.com'
) ON CONFLICT DO NOTHING;

ALTER TABLE public.store_settings ENABLE ROW LEVEL SECURITY;

CREATE POLICY "All authenticated users can read settings" ON public.store_settings
  FOR SELECT USING (auth.role() = 'authenticated');

CREATE POLICY "Admins can update settings" ON public.store_settings
  FOR UPDATE USING (
    EXISTS (
      SELECT 1 FROM public.users
      WHERE id = auth.uid() AND role = 'ADMIN'
    )
  );

-- =====================================================
-- 9. FUNCTIONS
-- =====================================================

-- Function to add new inventory item with batch tracking
CREATE OR REPLACE FUNCTION add_new_inventory_item(
  p_name TEXT,
  p_sku TEXT,
  p_category TEXT,
  p_quantity INTEGER,
  p_unit TEXT,
  p_price DECIMAL,
  p_cost_price DECIMAL,
  p_reorder_level INTEGER,
  p_expiry_date DATE,
  p_manufacturer TEXT,
  p_batch_number TEXT,
  p_supplier_id UUID,
  p_restock_invoice_number TEXT,
  p_user_id UUID
)
RETURNS JSON AS $$
DECLARE
  v_product_id UUID;
  v_batch_id UUID;
BEGIN
  -- Insert into inventory
  INSERT INTO public.inventory (
    name, sku, category, quantity, unit, price, cost_price,
    reorder_level, expiry_date, manufacturer, batch_number,
    supplier_id, restock_invoice_number, last_updated_by
  ) VALUES (
    p_name, p_sku, p_category, p_quantity, p_unit, p_price, p_cost_price,
    p_reorder_level, p_expiry_date, p_manufacturer, p_batch_number,
    p_supplier_id, p_restock_invoice_number, p_user_id
  ) RETURNING id INTO v_product_id;

  -- Insert into product_batches
  INSERT INTO public.product_batches (
    product_id, batch_number, expiry_date, quantity, cost_price
  ) VALUES (
    v_product_id, p_batch_number, p_expiry_date, p_quantity, p_cost_price
  ) RETURNING id INTO v_batch_id;

  -- Log stock movement
  INSERT INTO public.stock_movements (
    product_id, quantity_change, previous_quantity, new_quantity,
    type, reason, created_by, cost_price_at_time, unit_price_at_time
  ) VALUES (
    v_product_id, p_quantity, 0, p_quantity,
    'INITIAL', 'Initial stock entry', p_user_id, p_cost_price, p_price
  );

  RETURN json_build_object('id', v_product_id, 'batch_id', v_batch_id);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- =====================================================
-- 10. INDEXES FOR PERFORMANCE
-- =====================================================
CREATE INDEX IF NOT EXISTS idx_inventory_sku ON public.inventory(sku);
CREATE INDEX IF NOT EXISTS idx_inventory_category ON public.inventory(category);
CREATE INDEX IF NOT EXISTS idx_inventory_expiry ON public.inventory(expiry_date);
CREATE INDEX IF NOT EXISTS idx_sales_transaction_id ON public.sales(transaction_id);
CREATE INDEX IF NOT EXISTS idx_sales_cashier_id ON public.sales(cashier_id);
CREATE INDEX IF NOT EXISTS idx_sales_created_at ON public.sales(created_at);
CREATE INDEX IF NOT EXISTS idx_stock_movements_product_id ON public.stock_movements(product_id);
CREATE INDEX IF NOT EXISTS idx_stock_movements_created_at ON public.stock_movements(created_at);

-- =====================================================
-- SCHEMA CREATION COMPLETE
-- =====================================================
