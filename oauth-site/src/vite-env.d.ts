/// <reference types="vite/client" />

declare module 'lucide-react' {
  import React from 'react';
  export interface LucideProps extends React.SVGProps<SVGSVGElement> {
    size?: number | string;
    strokeWidth?: number | string;
    absoluteStrokeWidth?: boolean;
    color?: string;
  }
  export type LucideIcon = React.ForwardRefExoticComponent<
    LucideProps & React.RefAttributes<SVGSVGElement>
  >;

  export const ShieldCheck: LucideIcon;
  export const Lock: LucideIcon;
  export const Calendar: LucideIcon;
  export const UserCheck: LucideIcon;
  export const CheckCircle2: LucideIcon;
  export const CheckCircle: LucideIcon;
  export const FileText: LucideIcon;
  export const KeyRound: LucideIcon;
  export const ArrowRight: LucideIcon;
  export const ArrowLeft: LucideIcon;
  export const HelpCircle: LucideIcon;
  export const Clock: LucideIcon;
  export const Sparkles: LucideIcon;
  export const ExternalLink: LucideIcon;
  export const ChevronDown: LucideIcon;
  export const ChevronUp: LucideIcon;
  export const AlertCircle: LucideIcon;
  export const XCircle: LucideIcon;
  export const Trash2: LucideIcon;
  export const Copy: LucideIcon;
  export const Check: LucideIcon;
  export const ShieldAlert: LucideIcon;
  export const Mail: LucideIcon;
  export const Globe: LucideIcon;
  export const Menu: LucideIcon;
  export const X: LucideIcon;
  export const Sun: LucideIcon;
  export const EyeOff: LucideIcon;
  export const AlertTriangle: LucideIcon;
  export const FileCheck: LucideIcon;
  export const Scale: LucideIcon;
  export const Home: LucideIcon;
  const icons: Record<string, LucideIcon>;
  export default icons;
}
