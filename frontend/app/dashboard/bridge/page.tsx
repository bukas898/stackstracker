"use client"

import { useState } from "react"
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card"
import { Button } from "@/components/ui/button"
import { Input } from "@/components/ui/input"
import { Badge } from "@/components/ui/badge"
import { Progress } from "@/components/ui/progress"
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs"
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from "@/components/ui/table"
import { Tooltip, TooltipContent, TooltipProvider, TooltipTrigger } from "@/components/ui/tooltip"
import {
  ArrowLeftRight,
  ArrowDown,
  ArrowUp,
  Clock,
  CheckCircle,
  AlertCircle,
  Info,
  ExternalLink,
  Copy,
  Wallet,
} from "lucide-react"

// Sample bridge data
const bridgeStats = {
  totalBridged: "5,247 BTC",
  totalValue: "$243.2M",
  currentCapacity: "85%",
  avgBridgeTime: "45 min",
  networkFee: "0.0001 BTC",
  bridgeFee: "0.1%",
}

const pendingTransactions = [
  {
    id: "tx_001",
    type: "deposit",
    amount: "0.05 BTC",
    status: "confirming",
    progress: 60,
    confirmations: "3/6",
    estimatedTime: "15 min",
    txHash: "bc1q...7x8y",
    timestamp: "2 hours ago",
  },
  {
    id: "tx_002",
    type: "withdraw",
    amount: "0.12 sBTC",
    status: "processing",
    progress: 30,
    confirmations: "1/3",
    estimatedTime: "25 min",
    txHash: "SP2J...9EJ7",
    timestamp: "4 hours ago",
  },
]

const recentTransactions = [
  {
    id: "tx_003",
    type: "deposit",
    amount: "0.25 BTC → 0.25 sBTC",
    status: "completed",
    fee: "0.00025 BTC",
    timestamp: "1 day ago",
    txHash: "bc1q...9a2b",
  },
  {
    id: "tx_004",
    type: "withdraw",
    amount: "0.1 sBTC → 0.1 BTC",
    status: "completed",
    fee: "0.0001 BTC",
    timestamp: "3 days ago",
    txHash: "SP2J...4K5L",
  },
  {
    id: "tx_005",
    type: "deposit",
    amount: "0.5 BTC → 0.5 sBTC",
    status: "completed",
    fee: "0.0005 BTC",
    timestamp: "1 week ago",
    txHash: "bc1q...3c4d",
  },
]

export default function BridgePage() {
  const [bridgeDirection, setBridgeDirection] = useState<"deposit" | "withdraw">("deposit")
  const [amount, setAmount] = useState("")
  const [btcAddress, setBtcAddress] = useState("bc1qxy2kgdygjrsqtzq2n0yrf2493p83kkfjhx0wlh")
  const [stacksAddress, setStacksAddress] = useState("SP2J6ZY48GV1EZ5V2V5RB9MP66SW86PYKKNRV9EJ7")

  const getStatusIcon = (status: string) => {
    switch (status) {
      case "completed":
        return <CheckCircle className="w-4 h-4 text-success" />
      case "confirming":
      case "processing":
        return <Clock className="w-4 h-4 text-primary" />
      case "failed":
        return <AlertCircle className="w-4 h-4 text-destructive" />
      default:
        return <Clock className="w-4 h-4 text-muted-foreground" />
    }
  }

  const getStatusBadge = (status: string) => {
    switch (status) {
      case "completed":
        return <Badge className="bg-success/10 text-success border-success/20">Completed</Badge>
      case "confirming":
        return <Badge className="bg-primary/10 text-primary border-primary/20">Confirming</Badge>
      case "processing":
        return <Badge className="bg-primary/10 text-primary border-primary/20">Processing</Badge>
      case "failed":
        return <Badge variant="destructive">Failed</Badge>
      default:
        return <Badge variant="outline">Unknown</Badge>
    }
  }

  const handleBridge = () => {
    // Bridge logic would go here
    console.log(`Bridging ${amount} ${bridgeDirection === "deposit" ? "BTC to sBTC" : "sBTC to BTC"}`)
  }

  const copyToClipboard = (text: string) => {
    navigator.clipboard.writeText(text)
  }

  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-2xl font-bold text-foreground mb-2">sBTC Bridge</h1>
        <p className="text-muted-foreground">
          Bridge Bitcoin to sBTC and back with transaction tracking and status monitoring.
        </p>
      </div>

      {/* Bridge Statistics */}
      <div className="grid grid-cols-1 md:grid-cols-4 gap-6">
        <Card>
          <CardContent className="p-6">
            <div className="flex items-center justify-between">
              <div>
                <p className="text-sm text-muted-foreground">Total Bridged</p>
                <p className="text-2xl font-bold text-foreground font-mono">{bridgeStats.totalBridged}</p>
                <p className="text-sm text-muted-foreground">{bridgeStats.totalValue}</p>
              </div>
              <ArrowLeftRight className="w-8 h-8 text-primary" />
            </div>
          </CardContent>
        </Card>

        <Card>
          <CardContent className="p-6">
            <div className="flex items-center justify-between">
              <div>
                <p className="text-sm text-muted-foreground">Bridge Capacity</p>
                <p className="text-2xl font-bold text-foreground">{bridgeStats.currentCapacity}</p>
                <Progress value={85} className="mt-2" />
              </div>
              <div className="w-8 h-8 bg-success/10 rounded-lg flex items-center justify-center">
                <CheckCircle className="w-5 h-5 text-success" />
              </div>
            </div>
          </CardContent>
        </Card>

        <Card>
          <CardContent className="p-6">
            <div className="flex items-center justify-between">
              <div>
                <p className="text-sm text-muted-foreground">Avg Bridge Time</p>
                <p className="text-2xl font-bold text-foreground">{bridgeStats.avgBridgeTime}</p>
              </div>
              <Clock className="w-8 h-8 text-primary" />
            </div>
          </CardContent>
        </Card>

        <Card>
          <CardContent className="p-6">
            <div className="flex items-center justify-between">
              <div>
                <p className="text-sm text-muted-foreground">Bridge Fee</p>
                <p className="text-2xl font-bold text-foreground">{bridgeStats.bridgeFee}</p>
                <p className="text-sm text-muted-foreground">+ {bridgeStats.networkFee}</p>
              </div>
              <div className="w-8 h-8 bg-primary/10 rounded-lg flex items-center justify-center">
                <span className="text-sm font-bold text-primary">%</span>
              </div>
            </div>
          </CardContent>
        </Card>
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        {/* Bridge Interface */}
        <Card>
          <CardHeader>
            <CardTitle className="flex items-center gap-2">
              <ArrowLeftRight className="w-5 h-5" />
              Bridge Interface
            </CardTitle>
          </CardHeader>
          <CardContent className="space-y-6">
            {/* Direction Toggle */}
            <Tabs
              value={bridgeDirection}
              onValueChange={(value) => setBridgeDirection(value as "deposit" | "withdraw")}
            >
              <TabsList className="grid w-full grid-cols-2">
                <TabsTrigger value="deposit" className="flex items-center gap-2">
                  <ArrowDown className="w-4 h-4" />
                  Deposit (BTC → sBTC)
                </TabsTrigger>
                <TabsTrigger value="withdraw" className="flex items-center gap-2">
                  <ArrowUp className="w-4 h-4" />
                  Withdraw (sBTC → BTC)
                </TabsTrigger>
              </TabsList>

              <TabsContent value="deposit" className="space-y-4">
                <div className="space-y-4">
                  <div>
                    <label className="text-sm font-medium text-foreground mb-2 block">Amount to Bridge</label>
                    <div className="relative">
                      <Input
                        type="number"
                        placeholder="0.00"
                        value={amount}
                        onChange={(e) => setAmount(e.target.value)}
                        className="pr-16"
                      />
                      <div className="absolute right-3 top-1/2 -translate-y-1/2 text-sm text-muted-foreground">BTC</div>
                    </div>
                    <p className="text-xs text-muted-foreground mt-1">
                      You will receive: {amount || "0.00"} sBTC (1:1 ratio)
                    </p>
                  </div>

                  <div>
                    <label className="text-sm font-medium text-foreground mb-2 block flex items-center gap-2">
                      Bitcoin Address
                      <TooltipProvider>
                        <Tooltip>
                          <TooltipTrigger>
                            <Info className="w-4 h-4 text-muted-foreground" />
                          </TooltipTrigger>
                          <TooltipContent>
                            <p>Your Bitcoin address where funds will be sent from</p>
                          </TooltipContent>
                        </Tooltip>
                      </TooltipProvider>
                    </label>
                    <div className="flex gap-2">
                      <Input value={btcAddress} onChange={(e) => setBtcAddress(e.target.value)} className="font-mono" />
                      <Button variant="outline" size="sm" onClick={() => copyToClipboard(btcAddress)}>
                        <Copy className="w-4 h-4" />
                      </Button>
                    </div>
                  </div>
                </div>
              </TabsContent>

              <TabsContent value="withdraw" className="space-y-4">
                <div className="space-y-4">
                  <div>
                    <label className="text-sm font-medium text-foreground mb-2 block">Amount to Bridge</label>
                    <div className="relative">
                      <Input
                        type="number"
                        placeholder="0.00"
                        value={amount}
                        onChange={(e) => setAmount(e.target.value)}
                        className="pr-16"
                      />
                      <div className="absolute right-3 top-1/2 -translate-y-1/2 text-sm text-muted-foreground">
                        sBTC
                      </div>
                    </div>
                    <p className="text-xs text-muted-foreground mt-1">
                      You will receive: {amount || "0.00"} BTC (1:1 ratio)
                    </p>
                  </div>

                  <div>
                    <label className="text-sm font-medium text-foreground mb-2 block flex items-center gap-2">
                      Bitcoin Address
                      <TooltipProvider>
                        <Tooltip>
                          <TooltipTrigger>
                            <Info className="w-4 h-4 text-muted-foreground" />
                          </TooltipTrigger>
                          <TooltipContent>
                            <p>Your Bitcoin address where funds will be sent to</p>
                          </TooltipContent>
                        </Tooltip>
                      </TooltipProvider>
                    </label>
                    <div className="flex gap-2">
                      <Input value={btcAddress} onChange={(e) => setBtcAddress(e.target.value)} className="font-mono" />
                      <Button variant="outline" size="sm" onClick={() => copyToClipboard(btcAddress)}>
                        <Copy className="w-4 h-4" />
                      </Button>
                    </div>
                  </div>
                </div>
              </TabsContent>
            </Tabs>

            {/* Fee Breakdown */}
            <div className="bg-muted/50 rounded-lg p-4 space-y-2">
              <h4 className="font-medium text-foreground">Fee Breakdown</h4>
              <div className="space-y-1 text-sm">
                <div className="flex justify-between">
                  <span className="text-muted-foreground">Bridge Fee ({bridgeStats.bridgeFee})</span>
                  <span className="text-foreground">
                    {amount ? (Number.parseFloat(amount) * 0.001).toFixed(6) : "0.000000"} BTC
                  </span>
                </div>
                <div className="flex justify-between">
                  <span className="text-muted-foreground">Network Fee</span>
                  <span className="text-foreground">{bridgeStats.networkFee}</span>
                </div>
                <div className="border-t border-border pt-1 flex justify-between font-medium">
                  <span className="text-foreground">Total Fee</span>
                  <span className="text-foreground">
                    {amount ? (Number.parseFloat(amount) * 0.001 + 0.0001).toFixed(6) : "0.000100"} BTC
                  </span>
                </div>
              </div>
            </div>

            {/* Bridge Button */}
            <Button onClick={handleBridge} className="w-full" disabled={!amount || Number.parseFloat(amount) <= 0}>
              <Wallet className="w-4 h-4 mr-2" />
              {bridgeDirection === "deposit" ? "Bridge to sBTC" : "Bridge to BTC"}
            </Button>

            {/* Educational Info */}
            <div className="bg-primary/5 border border-primary/20 rounded-lg p-4">
              <div className="flex items-start gap-3">
                <Info className="w-5 h-5 text-primary mt-0.5" />
                <div className="space-y-2 text-sm">
                  <p className="font-medium text-foreground">How sBTC Bridge Works</p>
                  <p className="text-muted-foreground">
                    sBTC is a 1:1 Bitcoin-backed asset on Stacks. Deposits typically take 3-6 Bitcoin confirmations
                    (~30-60 minutes), while withdrawals require 3 Stacks confirmations (~15-30 minutes).
                  </p>
                </div>
              </div>
            </div>
          </CardContent>
        </Card>

        {/* Transaction Status */}
        <Card>
          <CardHeader>
            <CardTitle>Transaction Status</CardTitle>
          </CardHeader>
          <CardContent>
            <div className="space-y-4">
              <h4 className="font-medium text-foreground">Pending Transactions</h4>
              {pendingTransactions.length > 0 ? (
                <div className="space-y-4">
                  {pendingTransactions.map((tx) => (
                    <div key={tx.id} className="border border-border rounded-lg p-4">
                      <div className="flex items-center justify-between mb-3">
                        <div className="flex items-center gap-2">
                          {getStatusIcon(tx.status)}
                          <span className="font-medium text-foreground">
                            {tx.type === "deposit" ? "Deposit" : "Withdraw"} {tx.amount}
                          </span>
                        </div>
                        {getStatusBadge(tx.status)}
                      </div>

                      <div className="space-y-2">
                        <div className="flex justify-between text-sm">
                          <span className="text-muted-foreground">Progress</span>
                          <span className="text-foreground">{tx.confirmations}</span>
                        </div>
                        <Progress value={tx.progress} className="h-2" />
                        <div className="flex justify-between text-sm">
                          <span className="text-muted-foreground">Estimated Time</span>
                          <span className="text-foreground">{tx.estimatedTime}</span>
                        </div>
                        <div className="flex items-center gap-2 text-sm">
                          <span className="text-muted-foreground">TX:</span>
                          <span className="font-mono text-foreground">{tx.txHash}</span>
                          <Button variant="ghost" size="sm" className="h-6 w-6 p-0">
                            <ExternalLink className="w-3 h-3" />
                          </Button>
                        </div>
                      </div>
                    </div>
                  ))}
                </div>
              ) : (
                <p className="text-muted-foreground text-center py-8">No pending transactions</p>
              )}
            </div>
          </CardContent>
        </Card>
      </div>

      {/* Recent Transactions */}
      <Card>
        <CardHeader>
          <CardTitle>Recent Bridge Transactions</CardTitle>
        </CardHeader>
        <CardContent>
          <Table>
            <TableHeader>
              <TableRow>
                <TableHead>Type</TableHead>
                <TableHead>Amount</TableHead>
                <TableHead>Fee</TableHead>
                <TableHead>Status</TableHead>
                <TableHead>Time</TableHead>
                <TableHead>Transaction</TableHead>
              </TableRow>
            </TableHeader>
            <TableBody>
              {recentTransactions.map((tx) => (
                <TableRow key={tx.id}>
                  <TableCell>
                    <div className="flex items-center gap-2">
                      {tx.type === "deposit" ? (
                        <ArrowDown className="w-4 h-4 text-success" />
                      ) : (
                        <ArrowUp className="w-4 h-4 text-primary" />
                      )}
                      {tx.type === "deposit" ? "Deposit" : "Withdraw"}
                    </div>
                  </TableCell>
                  <TableCell className="font-mono">{tx.amount}</TableCell>
                  <TableCell className="font-mono text-muted-foreground">{tx.fee}</TableCell>
                  <TableCell>{getStatusBadge(tx.status)}</TableCell>
                  <TableCell className="text-muted-foreground">{tx.timestamp}</TableCell>
                  <TableCell>
                    <div className="flex items-center gap-2">
                      <span className="font-mono text-sm">{tx.txHash}</span>
                      <Button variant="ghost" size="sm" className="h-6 w-6 p-0">
                        <ExternalLink className="w-3 h-3" />
                      </Button>
                    </div>
                  </TableCell>
                </TableRow>
              ))}
            </TableBody>
          </Table>
        </CardContent>
      </Card>
    </div>
  )
}
