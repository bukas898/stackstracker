"use client"

import { useState } from "react"
import { Button } from "@/components/ui/button"
import { Card, CardContent } from "@/components/ui/card"
import { Badge } from "@/components/ui/badge"
import { TrendingUp, Shield, ArrowLeftRight, BarChart3 } from "lucide-react"
import { WalletConnectionModal } from "@/components/wallet-connection-modal"

export default function LandingPage() {
  const [walletModalOpen, setWalletModalOpen] = useState(false)

  return (
    <div className="min-h-screen bg-background">
      {/* Header */}
      <header className="border-b border-border bg-card">
        <div className="container mx-auto px-4 py-4 flex items-center justify-between">
          <div className="flex items-center gap-2">
            <div className="w-8 h-8 bg-primary rounded-lg flex items-center justify-center">
              <BarChart3 className="w-5 h-5 text-primary-foreground" />
            </div>
            <span className="text-xl font-bold text-foreground">StacksTracker</span>
          </div>
          <nav className="hidden md:flex items-center gap-6">
            <a href="#features" className="text-muted-foreground hover:text-foreground transition-colors">
              Features
            </a>
            <a href="#about" className="text-muted-foreground hover:text-foreground transition-colors">
              About
            </a>
            <a href="#docs" className="text-muted-foreground hover:text-foreground transition-colors">
              Docs
            </a>
          </nav>
        </div>
      </header>

      {/* Hero Section */}
      <section className="py-20 px-4">
        <div className="container mx-auto text-center max-w-4xl">
          <Badge variant="secondary" className="mb-4">
            Bitcoin-Secured DeFi
          </Badge>
          <h1 className="text-4xl md:text-6xl font-bold text-foreground mb-6 text-balance">
            Your Bitcoin DeFi Command Center
          </h1>
          <p className="text-xl text-muted-foreground mb-8 max-w-2xl mx-auto text-pretty">
            Track, manage, and optimize your Stacks DeFi positions with the security of Bitcoin and the power of smart
            contracts.
          </p>
          <div className="flex flex-col sm:flex-row gap-4 justify-center mb-12">
            <Button size="lg" className="text-lg px-8" onClick={() => setWalletModalOpen(true)}>
              Launch App
            </Button>
            <Button size="lg" variant="outline" className="text-lg px-8 bg-transparent">
              Try Demo
            </Button>
          </div>
        </div>
      </section>

      {/* Live Statistics Ticker */}
      <section className="py-8 bg-card border-y border-border">
        <div className="container mx-auto px-4">
          <div className="grid grid-cols-1 md:grid-cols-3 gap-8 text-center">
            <div className="space-y-2">
              <div className="text-2xl font-mono font-bold text-primary">$200M+</div>
              <div className="text-sm text-muted-foreground">Total Stacks TVL</div>
            </div>
            <div className="space-y-2">
              <div className="text-2xl font-mono font-bold text-primary">5,000+ BTC</div>
              <div className="text-sm text-muted-foreground">sBTC Bridged</div>
            </div>
            <div className="space-y-2">
              <div className="text-2xl font-mono font-bold text-primary">15K+</div>
              <div className="text-sm text-muted-foreground">Active Users</div>
            </div>
          </div>
        </div>
      </section>

      {/* Feature Highlights */}
      <section id="features" className="py-20 px-4">
        <div className="container mx-auto max-w-6xl">
          <div className="text-center mb-16">
            <h2 className="text-3xl md:text-4xl font-bold text-foreground mb-4">
              Everything you need for Bitcoin DeFi
            </h2>
            <p className="text-xl text-muted-foreground max-w-2xl mx-auto">
              Comprehensive tools to track, manage, and optimize your Stacks ecosystem investments.
            </p>
          </div>

          <div className="grid grid-cols-1 md:grid-cols-3 gap-8">
            <Card className="p-6 hover:shadow-lg transition-shadow">
              <CardContent className="p-0">
                <div className="w-12 h-12 bg-primary/10 rounded-lg flex items-center justify-center mb-4">
                  <BarChart3 className="w-6 h-6 text-primary" />
                </div>
                <h3 className="text-xl font-semibold text-foreground mb-2">Portfolio Tracking</h3>
                <p className="text-muted-foreground">
                  Real-time portfolio monitoring with detailed analytics, performance metrics, and asset allocation
                  insights.
                </p>
              </CardContent>
            </Card>

            <Card className="p-6 hover:shadow-lg transition-shadow">
              <CardContent className="p-0">
                <div className="w-12 h-12 bg-primary/10 rounded-lg flex items-center justify-center mb-4">
                  <TrendingUp className="w-6 h-6 text-primary" />
                </div>
                <h3 className="text-xl font-semibold text-foreground mb-2">DeFi Positions</h3>
                <p className="text-muted-foreground">
                  Manage positions across ALEX, Arkadiko, Velar, and Stacking protocols with yield optimization tools.
                </p>
              </CardContent>
            </Card>

            <Card className="p-6 hover:shadow-lg transition-shadow">
              <CardContent className="p-0">
                <div className="w-12 h-12 bg-primary/10 rounded-lg flex items-center justify-center mb-4">
                  <ArrowLeftRight className="w-6 h-6 text-primary" />
                </div>
                <h3 className="text-xl font-semibold text-foreground mb-2">sBTC Bridge Management</h3>
                <p className="text-muted-foreground">
                  Seamlessly bridge Bitcoin to sBTC and back with transaction tracking and status monitoring.
                </p>
              </CardContent>
            </Card>
          </div>
        </div>
      </section>

      {/* Value Proposition */}
      <section className="py-20 px-4 bg-card">
        <div className="container mx-auto max-w-4xl text-center">
          <div className="flex items-center justify-center gap-2 mb-6">
            <Shield className="w-8 h-8 text-primary" />
            <span className="text-2xl font-bold text-foreground">Bitcoin Security + DeFi Yields</span>
          </div>
          <p className="text-lg text-muted-foreground mb-8">
            Experience the best of both worlds: the security and stability of Bitcoin with the innovation and yields of
            decentralized finance on Stacks.
          </p>
          <div className="grid grid-cols-1 md:grid-cols-2 gap-8 text-left">
            <div className="space-y-4">
              <h4 className="font-semibold text-foreground flex items-center gap-2">
                <Shield className="w-5 h-5 text-primary" />
                Bitcoin-Level Security
              </h4>
              <p className="text-muted-foreground">
                All transactions are secured by Bitcoin's proof-of-work consensus, providing unmatched security for your
                DeFi activities.
              </p>
            </div>
            <div className="space-y-4">
              <h4 className="font-semibold text-foreground flex items-center gap-2">
                <TrendingUp className="w-5 h-5 text-primary" />
                Optimized Yields
              </h4>
              <p className="text-muted-foreground">
                Access high-yield opportunities across the Stacks ecosystem while maintaining full control of your
                assets.
              </p>
            </div>
          </div>
        </div>
      </section>

      {/* CTA Section */}
      <section className="py-20 px-4">
        <div className="container mx-auto text-center max-w-2xl">
          <h2 className="text-3xl md:text-4xl font-bold text-foreground mb-4">Ready to optimize your Bitcoin DeFi?</h2>
          <p className="text-xl text-muted-foreground mb-8">
            Join thousands of users already managing their Stacks DeFi positions with StacksTracker.
          </p>
          <div className="flex flex-col sm:flex-row gap-4 justify-center">
            <Button size="lg" className="text-lg px-8" onClick={() => setWalletModalOpen(true)}>
              Launch App
            </Button>
            <Button size="lg" variant="outline" className="text-lg px-8 bg-transparent">
              Try Demo
            </Button>
          </div>
        </div>
      </section>

      {/* Footer */}
      <footer className="border-t border-border bg-card py-12 px-4">
        <div className="container mx-auto">
          <div className="flex flex-col md:flex-row items-center justify-between">
            <div className="flex items-center gap-2 mb-4 md:mb-0">
              <div className="w-6 h-6 bg-primary rounded flex items-center justify-center">
                <BarChart3 className="w-4 h-4 text-primary-foreground" />
              </div>
              <span className="font-semibold text-foreground">StacksTracker</span>
            </div>
            <div className="flex items-center gap-6 text-sm text-muted-foreground">
              <a href="#" className="hover:text-foreground transition-colors">
                Privacy
              </a>
              <a href="#" className="hover:text-foreground transition-colors">
                Terms
              </a>
              <a href="#" className="hover:text-foreground transition-colors">
                Support
              </a>
            </div>
          </div>
          <div className="mt-8 pt-8 border-t border-border text-center text-sm text-muted-foreground">
            © 2024 StacksTracker. Built on Bitcoin, powered by Stacks.
          </div>
        </div>
      </footer>

      <WalletConnectionModal open={walletModalOpen} onOpenChange={setWalletModalOpen} />
    </div>
  )
}
