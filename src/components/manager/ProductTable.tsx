
import { Button } from "@/components/ui/button";
import { Badge } from "@/components/ui/badge";
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from "@/components/ui/table";
import { useToast } from "@/hooks/use-toast";
import { Package, RefreshCw } from "lucide-react";
import { Card, CardHeader, CardContent, CardTitle } from "@/components/ui/card";

interface Product {
  id: string | number;
  name: string;
  category: string;
  stock: number;
  expiry: string;
  status: "In Stock" | "Low Stock" | "Critical";
}

interface ProductTableProps {
  products: Product[];
  filteredProducts: Product[];
}

export const ProductTable = ({ products, filteredProducts }: ProductTableProps) => {
  const { toast } = useToast();

  return (
    <Card className="hover:shadow-lg transition-all duration-200">
      <CardHeader className="flex items-center justify-between">
        <CardTitle className="text-lg font-semibold flex items-center gap-2">
          <Package className="h-5 w-5 text-primary" />
          Product Inventory
        </CardTitle>
        <Button variant="outline" size="sm" className="h-8 gap-1">
          <RefreshCw className="h-3.5 w-3.5" />
          Refresh
        </Button>
      </CardHeader>
      <CardContent>
        <Table>
          <TableHeader className="bg-muted/30">
            <TableRow className="hover:bg-muted/50">
              <TableHead>Name</TableHead>
              <TableHead>Category</TableHead>
              <TableHead>Stock</TableHead>
              <TableHead>Expiry Date</TableHead>
              <TableHead>Status</TableHead>
              <TableHead>Actions</TableHead>
            </TableRow>
          </TableHeader>
          <TableBody>
            {filteredProducts.length === 0 ? (
              <TableRow>
                <TableCell colSpan={6} className="text-center py-8 text-muted-foreground">
                  No products found matching your search
                </TableCell>
              </TableRow>
            ) : (
              filteredProducts.map((product) => (
                <TableRow key={product.id} className="hover:bg-muted/50 cursor-pointer">
                  <TableCell className="font-medium">{product.name}</TableCell>
                  <TableCell>{product.category}</TableCell>
                  <TableCell>{product.stock}</TableCell>
                  <TableCell>{product.expiry}</TableCell>
                  <TableCell>
                    <Badge variant={
                      product.status === "In Stock"
                        ? "default"
                        : product.status === "Low Stock"
                          ? "outline"
                          : "destructive"
                    } className="font-medium">
                      {product.status}
                    </Badge>
                  </TableCell>
                  <TableCell>
                    <div className="flex space-x-2">
                      <Button
                        variant="outline"
                        size="sm"
                        className="h-8 px-3 text-xs hover:bg-muted/80"
                        onClick={() => {
                          toast({
                            title: "Not Implemented",
                            description: "Edit functionality would be implemented here",
                          });
                        }}
                      >
                        Edit
                      </Button>
                      <Button
                        variant="outline"
                        size="sm"
                        className="h-8 px-3 text-xs hover:bg-muted/80"
                        onClick={() => {
                          toast({
                            title: "Not Implemented",
                            description: "View details functionality would be implemented here",
                          });
                        }}
                      >
                        View
                      </Button>
                    </div>
                  </TableCell>
                </TableRow>
              ))
            )}
          </TableBody>
        </Table>
      </CardContent>
    </Card>
  );
};
