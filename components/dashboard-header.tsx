"use client"

import { Button } from "@/components/ui/button"
import { Badge } from "@/components/ui/badge"
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuSeparator,
  DropdownMenuTrigger,
} from "@/components/ui/dropdown-menu"
import { Settings, LogOut, User, Wallet, Globe, Bell } from "lucide-react"

export function DashboardHeader() {
  // Mock wallet data - in real app this would come from wallet context
  const walletAddress = "SP2J6ZY48GV1EZ5V2V5RB9MP66SW86PYKKNRV9EJ7"
  const networkStatus = "mainnet"
  const isConnected = true

  return (
    <header className="bg-card border-b border-border px-6 py-4">
      <div className="flex items-center justify-between">
        {/* Left side - Page context could go here */}
        <div className="flex items-center gap-4">
          <h1 className="text-xl font-semibold text-foreground">Dashboard</h1>
        </div>

        {/* Right side - Wallet info and controls */}
        <div className="flex items-center gap-4">
          {/* Network Status */}
          <div className="flex items-center gap-2">
            <div className="w-2 h-2 bg-success rounded-full"></div>
            <Badge variant="secondary" className="text-xs">
              <Globe className="w-3 h-3 mr-1" />
              {networkStatus}
            </Badge>
          </div>

          {/* Notifications */}
          <Button variant="ghost" size="sm" className="h-8 w-8 p-0">
            <Bell className="w-4 h-4" />
          </Button>

          {/* Wallet Dropdown */}
          <DropdownMenu>
            <DropdownMenuTrigger asChild>
              <Button variant="outline" className="flex items-center gap-2 bg-transparent">
                <Wallet className="w-4 h-4" />
                <span className="hidden sm:inline font-mono text-sm">
                  {walletAddress.slice(0, 6)}...{walletAddress.slice(-4)}
                </span>
              </Button>
            </DropdownMenuTrigger>
            <DropdownMenuContent align="end" className="w-56">
              <div className="px-2 py-1.5">
                <div className="text-sm font-medium text-foreground">Connected Wallet</div>
                <div className="text-xs text-muted-foreground font-mono">{walletAddress}</div>
              </div>
              <DropdownMenuSeparator />
              <DropdownMenuItem>
                <User className="w-4 h-4 mr-2" />
                Profile
              </DropdownMenuItem>
              <DropdownMenuItem>
                <Settings className="w-4 h-4 mr-2" />
                Settings
              </DropdownMenuItem>
              <DropdownMenuSeparator />
              <DropdownMenuItem className="text-destructive">
                <LogOut className="w-4 h-4 mr-2" />
                Disconnect Wallet
              </DropdownMenuItem>
            </DropdownMenuContent>
          </DropdownMenu>
        </div>
      </div>
    </header>
  )
}
