
import { useState, useEffect } from "react";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { useToast } from "@/hooks/use-toast";
import { ProductForm } from "@/components/manager/ProductForm";
import { ManagerHeader } from "@/components/manager/ManagerHeader";
import { ProductStats } from "@/components/manager/ProductStats";
import { ProductTable } from "@/components/manager/ProductTable";
import { useIsMobile } from "@/hooks/use-mobile";
import { useNavigate } from "react-router-dom";
import { EnhancedTransactionsCard } from "@/components/admin/EnhancedTransactionsCard";
import { EnhancedLowStockCard } from "@/components/admin/EnhancedLowStockCard";
import { useInventory } from "@/hooks/useInventory";
import { supabase } from "@/integrations/supabase/client";

interface Product {
  id: string | number;
  name: string;
  category: string;
  stock: number;
  expiry: string;
  status: "In Stock" | "Low Stock" | "Critical";
}

const ManagerDashboard = () => {
  const { toast } = useToast();
  const [searchQuery, setSearchQuery] = useState("");
  const [showProductForm, setShowProductForm] = useState(false);
  const isMobile = useIsMobile();
  const navigate = useNavigate();
  const { inventory, isLoading } = useInventory();
  const [recentTransactions, setRecentTransactions] = useState<any[]>([]);

  // Map inventory to products format
  const products: Product[] = inventory.map(item => {
    let status: "In Stock" | "Low Stock" | "Critical" = "In Stock";
    if (item.quantity <= 0) status = "Critical";
    else if (item.quantity <= item.reorderLevel) status = "Low Stock";

    return {
      id: item.id,
      name: item.name,
      category: item.category,
      stock: item.quantity,
      expiry: item.expiryDate ? new Date(item.expiryDate).toLocaleDateString() : 'N/A',
      status: status
    };
  });

  const filteredProducts = products.filter(
    prod =>
      prod.name.toLowerCase().includes(searchQuery.toLowerCase()) ||
      prod.category.toLowerCase().includes(searchQuery.toLowerCase()) ||
      prod.status.toLowerCase().includes(searchQuery.toLowerCase())
  );

  const lowStockCount = products.filter(prod => prod.status === "Low Stock").length;
  const criticalStockCount = products.filter(prod => prod.status === "Critical").length;

  // Calculate expiring soon (within 30 days)
  const expiringSoonCount = inventory.filter(item => {
    if (!item.expiryDate) return false;
    const expiry = new Date(item.expiryDate);
    const today = new Date();
    const diffTime = expiry.getTime() - today.getTime();
    const diffDays = Math.ceil(diffTime / (1000 * 60 * 60 * 24));
    return diffDays > 0 && diffDays <= 30;
  }).length;

  useEffect(() => {
    const fetchTransactions = async () => {
      const { data: transactions, error } = await supabase
        .from('sales')
        .select('*')
        .order('created_at', { ascending: false })
        .limit(5);

      if (transactions) {
        const formattedTx = transactions.map(tx => ({
          id: tx.transaction_id || tx.id,
          product: tx.customer_name || 'Walk-in Customer',
          customer: `Items: ${(tx.items && Array.isArray(tx.items)) ? tx.items.length : 'N/A'}`,
          amount: Number(tx.total || tx.total_amount || 0),
          date: new Date(tx.created_at).toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' })
        }));
        setRecentTransactions(formattedTx);
      }
    };
    fetchTransactions();
  }, []);

  // Low stock items for card
  const lowStockItems = inventory
    .filter(item => item.quantity <= item.reorderLevel)
    .slice(0, 3)
    .map((item, index) => ({
      id: item.id,
      product: item.name,
      category: item.category,
      quantity: item.quantity,
      reorderLevel: item.reorderLevel,
    }));

  const handleProductComplete = (isNew: boolean) => {
    toast({
      title: isNew ? "Product Added" : "Product Updated",
      description: isNew ? "The product was added successfully" : "The product was updated successfully",
    });
    setShowProductForm(false);
  };

  const handleCardClick = (route: string) => {
    navigate(route);
  };

  const handleItemClick = (route: string, id: number | string) => {
    navigate(route);
  };

  return (
    <div className="space-y-4 md:space-y-6 animate-fade-in px-2 md:px-0">
      <ManagerHeader
        searchQuery={searchQuery}
        setSearchQuery={setSearchQuery}
        onAddProduct={() => setShowProductForm(true)}
      />

      {showProductForm ? (
        <Card className="border-2 border-primary/10">
          <CardHeader className="p-4 md:p-6">
            <CardTitle className="text-xl md:text-2xl">Add New Product</CardTitle>
          </CardHeader>
          <CardContent className="p-4 md:p-6">
            <ProductForm
              onComplete={(isNew) => handleProductComplete(isNew)}
              onCancel={() => setShowProductForm(false)}
            />
          </CardContent>
        </Card>
      ) : (
        <>
          <ProductStats
            totalProducts={products.length}
            lowStockCount={lowStockCount}
            criticalStockCount={criticalStockCount}
            expiringSoonCount={expiringSoonCount}
            onCardClick={handleCardClick}
          />

          <div className="grid gap-4 md:grid-cols-2">
            <EnhancedTransactionsCard
              transactions={recentTransactions}
              onItemClick={handleItemClick}
              onViewAllClick={handleCardClick}
            />

            <EnhancedLowStockCard
              items={lowStockItems}
              onItemClick={handleItemClick}
              onViewAllClick={handleCardClick}
            />
          </div>

          <div className="overflow-x-auto">
            <ProductTable
              products={products}
              filteredProducts={filteredProducts}
            />
          </div>
        </>
      )}
    </div>
  );
};

export default ManagerDashboard;
