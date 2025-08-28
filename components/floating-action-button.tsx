"use client"
import { Button } from "@/components/ui/button"
import { DropdownMenu, DropdownMenuContent, DropdownMenuItem, DropdownMenuTrigger } from "@/components/ui/dropdown-menu"
import { Plus, ArrowLeftRight, Repeat, Zap } from "lucide-react"

export function FloatingActionButton() {
  return (
    <div className="fixed bottom-6 right-6 z-50">
      <DropdownMenu>
        <DropdownMenuTrigger asChild>
          <Button size="lg" className="h-14 w-14 rounded-full shadow-lg hover:shadow-xl transition-shadow">
            <Plus className="w-6 h-6" />
          </Button>
        </DropdownMenuTrigger>
        <DropdownMenuContent align="end" className="w-48">
          <DropdownMenuItem>
            <ArrowLeftRight className="w-4 h-4 mr-2" />
            Bridge Bitcoin
          </DropdownMenuItem>
          <DropdownMenuItem>
            <Repeat className="w-4 h-4 mr-2" />
            Swap Tokens
          </DropdownMenuItem>
          <DropdownMenuItem>
            <Zap className="w-4 h-4 mr-2" />
            Stake STX
          </DropdownMenuItem>
        </DropdownMenuContent>
      </DropdownMenu>
    </div>
  )
}
