"use client"

import { useState } from "react"
import Link from "next/link"
import { usePathname } from "next/navigation"
import { cn } from "@/lib/utils"
import { Button } from "@/components/ui/button"
import { Home, TrendingUp, ArrowLeftRight, List, BarChart3, ChevronLeft, ChevronRight } from "lucide-react"

const navigation = [
  {
    name: "Portfolio Overview",
    href: "/dashboard",
    icon: Home,
  },
  {
    name: "DeFi Positions",
    href: "/dashboard/defi",
    icon: TrendingUp,
  },
  {
    name: "sBTC Bridge",
    href: "/dashboard/bridge",
    icon: ArrowLeftRight,
  },
  {
    name: "Transactions",
    href: "/dashboard/transactions",
    icon: List,
  },
]

export function DashboardSidebar() {
  const [collapsed, setCollapsed] = useState(false)
  const pathname = usePathname()

  return (
    <div
      className={cn(
        "bg-card border-r border-border flex flex-col transition-all duration-300",
        collapsed ? "w-16" : "w-60",
      )}
    >
      {/* Logo and Collapse Button */}
      <div className="p-4 border-b border-border">
        <div className="flex items-center justify-between">
          {!collapsed && (
            <div className="flex items-center gap-2">
              <div className="w-8 h-8 bg-primary rounded-lg flex items-center justify-center">
                <BarChart3 className="w-5 h-5 text-primary-foreground" />
              </div>
              <span className="text-lg font-bold text-foreground">StacksTracker</span>
            </div>
          )}
          <Button variant="ghost" size="sm" onClick={() => setCollapsed(!collapsed)} className="h-8 w-8 p-0">
            {collapsed ? <ChevronRight className="w-4 h-4" /> : <ChevronLeft className="w-4 h-4" />}
          </Button>
        </div>
      </div>

      {/* Navigation */}
      <nav className="flex-1 p-4">
        <div className="space-y-2">
          {navigation.map((item) => {
            const isActive = pathname === item.href
            return (
              <Link key={item.name} href={item.href}>
                <Button
                  variant={isActive ? "default" : "ghost"}
                  className={cn("w-full justify-start gap-3 h-10", collapsed && "justify-center px-2")}
                >
                  <item.icon className="w-5 h-5 flex-shrink-0" />
                  {!collapsed && <span>{item.name}</span>}
                </Button>
              </Link>
            )
          })}
        </div>
      </nav>

      {/* Footer */}
      <div className="p-4 border-t border-border">
        {!collapsed && <div className="text-xs text-muted-foreground text-center">v1.0.0 • Built on Stacks</div>}
      </div>
    </div>
  )
}
