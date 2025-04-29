import { cva } from "class-variance-authority";
import { twMerge } from "tailwind-merge";

//only text, only icon, and button with both text and icon

const button = cva(["inline-flex", "items-center", "justify-center", "gap-2"], {
  variants: {
    intent: {
      primary: ["bg-blue-500", "text-white", "hover:bg-blue-600"],
      secondary: ["bg-gray-500", "text-white", "hover:bg-gray-600"],
      danger: ["bg-red-500", "text-white", "hover:bg-red-600"],
      success: ["bg-green-500", "text-white", "hover:bg-green-600"],
      warning: ["bg-yellow-500", "text-white", "hover:bg-yellow-600"],
      info: ["bg-blue-300", "text-white", "hover:bg-blue-400"],
      light: ["bg-gray-200", "text-gray-800", "hover:bg-gray-300"],
      dark: ["bg-gray-800", "text-white", "hover:bg-gray-900"],
      ghost: ["bg-gray-100", "text-gray-800", "hover:bg-gray-200"],
      link: ["bg-transparent", "text-blue-500", "hover:bg-blue-100"],
    },
    size: {
      sm: ["text-sm", "px-2", "py-1"],
      md: ["text-base", "px-4", "py-2"],
      lg: ["text-lg", "px-6", "py-3"],
      xl: ["text-xl", "px-8", "py-4"],
    },
    shape: {
      rounded: ["rounded-full"],
      square: ["rounded-none"],
      pill: ["rounded-lg"],
      circle: ["rounded-full"],
    },
    fullWidth: {
      true: ["w-full"],
      false: ["w-auto"],
    },
    disabled: {
      true: ["opacity-50", "cursor-not-allowed"],
      false: ["cursor-pointer"],
    },
    btnType: {
      button: "",
      icon: ["p-0", "rounded-full"],
    },
  },
  compoundVariants: [
    {
      intent: ["primary", "secondary", "danger", "success", "warning", "info"],
      disabled: true,
      className: ["bg-gray-400", "text-gray-200"],
    },
    {
      btnType: "icon",
      size: "sm",
      className: ["size-10"],
    },
    {
      btnType: "icon",
      size: "md",
      className: ["size-12"],
    },
    {
      btnType: "icon",
      size: "lg",
      className: ["size-14"],
    },
    {
      btnType: "icon",
      size: "xl",
      className: ["size-16"],
    },
  ],
  defaultVariants: {
    intent: "primary",
    size: "md",
    shape: "rounded",
    fullWidth: false,
    disabled: false,
    btnType: "button",
  },
});

const Button = ({
  children,
  intent = "primary",
  size = "md",
  shape = "rounded",
  fullWidth = false,
  disabled = false,
  btnType = "button",
  className = "",
  ...props
}) => {
  return (
    <button
      className={twMerge(
        button({
          intent,
          size,
          shape,
          fullWidth,
          disabled,
          btnType,
          className,
        })
      )}
      disabled={disabled}
      {...props}
    >
      {children}
    </button>
  );
};

export default Button;
