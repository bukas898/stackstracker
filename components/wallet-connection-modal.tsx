"use client"

import { useState } from "react"
import { Dialog, DialogContent, DialogHeader, DialogTitle } from "@/components/ui/dialog"
import { Button } from "@/components/ui/button"
import { Card, CardContent } from "@/components/ui/card"
import { Badge } from "@/components/ui/badge"
import { Loader2, Wallet, CheckCircle, AlertCircle } from "lucide-react"

interface WalletConnectionModalProps {
  open: boolean
  onOpenChange: (open: boolean) => void
}

type WalletType = "leather" | "xverse"
type ConnectionStatus = "idle" | "connecting" | "connected" | "error"

export function WalletConnectionModal({ open, onOpenChange }: WalletConnectionModalProps) {
  const [selectedWallet, setSelectedWallet] = useState<WalletType | null>(null)
  const [connectionStatus, setConnectionStatus] = useState<ConnectionStatus>("idle")
  const [error, setError] = useState<string>("")

  const wallets = [
    {
      id: "leather" as WalletType,
      name: "Leather Wallet",
      description: "The original Stacks wallet by Hiro",
      icon: "🔶",
      detected: typeof window !== "undefined" && window.LeatherProvider,
    },
    {
      id: "xverse" as WalletType,
      name: "Xverse Wallet",
      description: "Multi-chain Bitcoin wallet",
      icon: "⚡",
      detected: typeof window !== "undefined" && window.XverseProviders,
    },
  ]

  const handleWalletConnect = async (walletType: WalletType) => {
    setSelectedWallet(walletType)
    setConnectionStatus("connecting")
    setError("")

    try {
      // Simulate wallet connection process
      await new Promise((resolve) => setTimeout(resolve, 2000))

      // Simulate random connection success/failure for demo
      if (Math.random() > 0.2) {
        setConnectionStatus("connected")
        setTimeout(() => {
          onOpenChange(false)
          // In a real app, this would redirect to the dashboard
          window.location.href = "/dashboard"
        }, 1500)
      } else {
        throw new Error("Failed to connect to wallet")
      }
    } catch (err) {
      setConnectionStatus("error")
      setError(err instanceof Error ? err.message : "Connection failed")
    }
  }

  const resetConnection = () => {
    setSelectedWallet(null)
    setConnectionStatus("idle")
    setError("")
  }

  return (
    <Dialog open={open} onOpenChange={onOpenChange}>
      <DialogContent className="sm:max-w-md">
        <DialogHeader>
          <DialogTitle className="flex items-center gap-2">
            <Wallet className="w-5 h-5" />
            Connect Wallet
          </DialogTitle>
        </DialogHeader>

        <div className="space-y-4">
          {connectionStatus === "idle" && (
            <>
              <p className="text-sm text-muted-foreground">
                Connect your wallet to access StacksTracker and manage your Bitcoin DeFi positions.
              </p>

              <div className="space-y-3">
                {wallets.map((wallet) => (
                  <Card
                    key={wallet.id}
                    className={`cursor-pointer transition-all hover:shadow-md ${!wallet.detected ? "opacity-50" : ""}`}
                    onClick={() => wallet.detected && handleWalletConnect(wallet.id)}
                  >
                    <CardContent className="p-4">
                      <div className="flex items-center justify-between">
                        <div className="flex items-center gap-3">
                          <div className="text-2xl">{wallet.icon}</div>
                          <div>
                            <div className="font-medium text-foreground">{wallet.name}</div>
                            <div className="text-sm text-muted-foreground">{wallet.description}</div>
                          </div>
                        </div>
                        <div className="flex items-center gap-2">
                          {wallet.detected ? (
                            <Badge variant="secondary" className="text-xs">
                              Detected
                            </Badge>
                          ) : (
                            <Badge variant="outline" className="text-xs">
                              Not Found
                            </Badge>
                          )}
                        </div>
                      </div>
                    </CardContent>
                  </Card>
                ))}
              </div>

              <div className="text-xs text-muted-foreground text-center">
                Don't have a wallet?{" "}
                <a
                  href="https://leather.io"
                  target="_blank"
                  rel="noopener noreferrer"
                  className="text-primary hover:underline"
                >
                  Get Leather
                </a>{" "}
                or{" "}
                <a
                  href="https://xverse.app"
                  target="_blank"
                  rel="noopener noreferrer"
                  className="text-primary hover:underline"
                >
                  Get Xverse
                </a>
              </div>
            </>
          )}

          {connectionStatus === "connecting" && selectedWallet && (
            <div className="text-center py-8">
              <Loader2 className="w-8 h-8 animate-spin mx-auto mb-4 text-primary" />
              <h3 className="font-medium text-foreground mb-2">
                Connecting to {selectedWallet === "leather" ? "Leather" : "Xverse"}
              </h3>
              <p className="text-sm text-muted-foreground mb-4">
                Please approve the connection in your wallet extension.
              </p>
              <div className="space-y-2 text-xs text-muted-foreground">
                <div className="flex items-center justify-center gap-2">
                  <div className="w-2 h-2 bg-primary rounded-full animate-pulse"></div>
                  Detecting wallet...
                </div>
                <div className="flex items-center justify-center gap-2">
                  <div className="w-2 h-2 bg-muted rounded-full"></div>
                  Requesting connection...
                </div>
                <div className="flex items-center justify-center gap-2">
                  <div className="w-2 h-2 bg-muted rounded-full"></div>
                  Verifying network...
                </div>
              </div>
            </div>
          )}

          {connectionStatus === "connected" && (
            <div className="text-center py-8">
              <CheckCircle className="w-8 h-8 mx-auto mb-4 text-success" />
              <h3 className="font-medium text-foreground mb-2">Successfully Connected!</h3>
              <p className="text-sm text-muted-foreground">Redirecting to your dashboard...</p>
            </div>
          )}

          {connectionStatus === "error" && (
            <div className="text-center py-8">
              <AlertCircle className="w-8 h-8 mx-auto mb-4 text-destructive" />
              <h3 className="font-medium text-foreground mb-2">Connection Failed</h3>
              <p className="text-sm text-muted-foreground mb-4">{error}</p>
              <div className="flex gap-2 justify-center">
                <Button variant="outline" onClick={resetConnection}>
                  Try Again
                </Button>
                <Button onClick={() => onOpenChange(false)}>Close</Button>
              </div>
            </div>
          )}
        </div>
      </DialogContent>
    </Dialog>
  )
}
